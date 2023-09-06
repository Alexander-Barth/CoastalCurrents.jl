module Altimetry


using Dates
using NCDatasets
using Base.Threads
using DataStructures
using ProgressMeter

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

end


iscomplete(fname) = NCDataset(fname) do ds
    haskey(ds,"mdt")
end

end
