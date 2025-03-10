module Altimetry

import CoastalCurrents
using Dates
using NCDatasets
using Base.Threads
using DataStructures
using ProgressMeter
using PhysOcean
using GeoMapping

# ---

# see section I.9.1
# https://catalogue.marine.copernicus.eu/documents/PUM/CMEMS-SL-PUM-008-032-068.pdf
# https://doi.org/10.48670/moi-00139

const mission_ids = ["e1","e1g","e2","tp","tpn","g2","j1","j1n","j1g",
                     "j2","j2n","j2g","j3","j3n","en","enn","c2","c2n",
                     "al","alg","h2a","h2ag","h2b","h2c","s3a","s3b",
                     "s6a-hr","s6a-lr","s6a"]



function getdate(fname)
    try
        Date(split(basename(fname),"_")[6],"yyyymmdd")
    catch
        error("unable to parse $fname")
    end
end
getpn(fname,mission_ids) = findfirst(mission_ids .== split(basename(fname),"_")[3])

function load(fname::AbstractString,mission_ids)
    @debug "loading $fname"
    ds = Dataset(fname);
    lon = mod.(nomissing(ds["longitude"][:],NaN) .+ 180,360) .- 180;
    lat = nomissing(ds["latitude"][:],NaN);
    time = nomissing(ds["time"][:]);
    slaf = nomissing(ds["sla_filtered"][:],NaN);
    sla = nomissing(ds["sla_unfiltered"][:],NaN);
    mdt = nomissing(ds["mdt"][:],NaN);

    track = nomissing(ds["track"][:]);
    cycle = nomissing(ds["cycle"][:]);
    platform = ds.attrib["platform"]

    @assert ds["sla_filtered"].attrib["units"] == "m"
    @assert ds["sla_unfiltered"].attrib["units"] == "m"
    @assert ds["mdt"].attrib["units"] == "m"

    id = getpn(fname,mission_ids) * 10_000_000 .+ track * 1000 .+ cycle
    close(ds)
    return sla,slaf,mdt,lon,lat,time,id
end


function load(fnames::Vector{<:AbstractString},lonr,latr,mission_ids)
    @info "check complete files"
    complete = @showprogress [Altimetry.iscomplete(fname) for fname in fnames]

    fnames = fnames[complete]

    @debug begin
        @show fnames[.!complete]
    end

    @info "load files"
    data = @showprogress [load(fname,lonr,latr,mission_ids) for fname in fnames]
    return ntuple(i -> reduce(vcat,getindex.(data,i)),7);
end

function load(fname::AbstractString,lonr,latr,mission_ids)
    sla,slaf,mdt,lon,lat,time,id = load(fname,mission_ids)
    sel = (lonr[1] .<= lon .<= lonr[end]) .& (latr[1] .<= lat .<= latr[end])
    return sla[sel],slaf[sel],mdt[sel],lon[sel],lat[sel],time[sel],id[sel]
end


function save(altimetry_fname,lon,lat,time,sla,slaf,mdt,id)
    len = ones(Int,length(lon))
    j = 1
    for i = 2:length(id)
        if id[i-1] == id[i]
            len[j] += 1
        else
            j += 1
        end
    end
    len = len[1:j]
    
    println(pwd())
    @assert length(unique(id)) == length(len)
    @assert length(id) == sum(len)

    isfile(altimetry_fname) && rm(altimetry_fname)

    ds = NCDataset(altimetry_fname,"c")


    defVar(ds,"len",len,("track",),
           attrib = OrderedDict(
               "long_name" => "number of observations for track",
               "sample_dimension" => "time",
           ));

    defVar(ds,"lon",lon,("time",),
           attrib = OrderedDict(
               "standard_name" => "longitude",
               "units" => "degrees_east",
           ))

    defVar(ds,"lat",lat,("time",),
           attrib = OrderedDict(
               "standard_name" => "latitude",
               "units" => "degrees_north",
           ))

    defVar(ds,"time",time,("time",),
           attrib = OrderedDict(
               "standard_name" => "time",
               "units" => "days since 1950-01-01 00:00:00",
           ))

    defVar(ds,"sla",sla,("time",),
           attrib = OrderedDict(
               "standard_name" => "sea_surface_height_above_sea_level",
               "units" => "m",
           ))
    defVar(ds,"slaf",slaf,("time",),
           attrib = OrderedDict(
               "standard_name" => "sea_surface_height_above_sea_level",
               "units" => "m",
           ))
    defVar(ds,"mdt",mdt,("time",),
           attrib = OrderedDict(
               "standard_name" => "sea_surface_height_above_geoid",
               "units" => "m",
           ))

    defVar(ds,"id",id,("time",))
    #defVar(ds,"dtime",time,("time",), attrib = OrderedDict("long_name" => "time of measurement"))

    close(ds)
    return nothing
end


iscomplete(fname) = NCDataset(fname) do ds
    haskey(ds,"mdt")
end

"""
    files = download(url,basedir,username,password; download_level = 5, force = false)

Recursive download of all files under the FTP `url` using the provided
credentials. Set the maximum number of subdirectories that this script
will recurse into to is 5  (`download_level`).
The download is skippped if the files are already present (unless force is
`true`).
"""
function download(url,basedir,username,password; download_level = 5, force = false)

    product_id = basename(url)

    if !isdir(joinpath(basedir,product_id)) && !force
        cd(basedir) do
            run(`wget --no-parent --recursive --level=$(download_level) -nH --cut-dirs=1  --user=$(username) --password=$(password) $(url)`) #run cmd, avec les backticks
        end
    end

    fnames = CoastalCurrents.listfiles(joinpath(basedir,product_id), extension = ".nc")
end



function perp_velocity!(lon,lat,adt,u,v)
    Re = PhysOcean.MEAN_RADIUS_EARTH
    for i = 1:length(lon)-1
        lonc = (lon[i+1] + lon[i])/2
        latc = (lat[i+1] + lat[i])/2

        f = PhysOcean.coriolisfrequency(latc)
        g = PhysOcean.earthgravity(latc)

        ds = π*Re/180 * GeoMapping.distance(lat[i+1],lon[i+1],lat[i],lon[i])

        ut = g/f * (adt[i+1]-adt[i]) / ds 

        az = GeoMapping.azimuth(latc,lonc,lat[i+1],lon[i+1])
        u[i] = -ut * cosd(-az)
        v[i] = -ut * sind(-az)
    end

    return (u,v)
end

function perp_velocity(lon,lat,adt)
    latc = (lat[1:end-1] + lat[2:end])/2
    lonc = (lon[1:end-1] + lon[2:end])/2

    u = zeros(length(latc))
    v = zeros(length(lonc))
    perp_velocity!(lon,lat,adt,u,v)
    return (lonc,latc,u,v)
end

function alloc_ragged(T,lenc)
    i = cumsum(lenc)
    tmp = Vector{T}(undef,sum(lenc))
    return [view(tmp,i[k]-lenc[k]+1 : i[k]) for k = 1:length(lenc)]
end

function geostrophic_velocity(lon,lat,time,adt)
    len = length.(adt)
    lenc = len .- 1

    lona = alloc_ragged(Float64,lenc)
    lata = alloc_ragged(Float64,lenc)
    ua = alloc_ragged(Float64,lenc)
    va = alloc_ragged(Float64,lenc)
    timea = alloc_ragged(DateTime,lenc)



    k = 0
    kc = 0

    # loop for every track
    for (lonc_,latc_,timec_,uc_,vc_,lon_,lat_,time_,adt_) in
        zip(lona,lata,timea,ua,va,lon,lat,time,adt)

        # loop along track
        for l = 1:length(lonc_)
            lonc_[l] = (lon_[l+1]+lon_[l])/2
            latc_[l] = (lat_[l+1]+lat_[l])/2

            timec_[l] = Dates.epochms2datetime(
                (Dates.datetime2epochms.(time_[l+1]) +
                    Dates.datetime2epochms.(time_[l])) ÷ 2)
        end

        perp_velocity!(lon_,lat_,adt_,uc_,vc_)
    end

    return (lona,lata,timea,ua,va)
end



end # module
