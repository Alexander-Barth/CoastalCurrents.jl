using Dates
using NCDatasets
using Base.Threads
using DataStructures

#outname = expanduser("~/tmp/BlueCloud2026/Altimetry/all-sla.nc")
varname = "sla"


# see section I.9.1
# https://catalogue.marine.copernicus.eu/documents/PUM/CMEMS-SL-PUM-008-032-068.pdf
# https://doi.org/10.48670/moi-00139

const mission_ids = ["e1","e1g","e2","tp","tpn","g2","j1","j1n","j1g",
                     "j2","j2n","j2g","j3","j3n","en","enn","c2","c2n",
                     "al","alg","h2a","h2ag","h2b","h2c","s3a","s3b",
                     "s6a-hr","s6a-lr"]


function listfiles(topdir = "."; extension = "")
    list = String[]

    for (root,dirs,files) in walkdir(topdir)
        for file in files
            if length(extension) == 0
                push!(list, joinpath(root, file))
            else
                if endswith(file,extension)
                    push!(list, joinpath(root, file))
                end
            end
        end
    end
    return list
end


getdate(fname) = Date(split(basename(fname),"_")[6],"yyyymmdd")
getpn(fname) = findfirst(mission_ids .== split(basename(fname),"_")[3])

function load(fname::AbstractString)
    ds = Dataset(fname);
    lon = mod.(nomissing(ds["longitude"][:],NaN) .+ 180,360) .- 180;
    lat = nomissing(ds["latitude"][:],NaN);
    time = nomissing(ds["time"][:]);
    slaf = nomissing(ds["sla_filtered"][:],NaN);
    sla = nomissing(ds["sla_unfiltered"][:],NaN);

    track = nomissing(ds["track"][:]);
    cycle = nomissing(ds["cycle"][:]);
    platform = ds.attrib["platform"]

    id = getpn(fname) * 10_000_000 .+ track * 1000 .+ cycle
    close(ds)
    return sla,slaf,lon,lat,time,id
end


function load(fnames::Vector{<:AbstractString},lonr,latr)
    data = load.(fnames,Ref(lonr),Ref(latr))
    return ntuple(i -> reduce(vcat,getindex.(data,i)),6);
end

function load(fname::AbstractString,lonr,latr)
    sla,slaf,lon,lat,time,id = load(fname)
    sel = (lonr[1] .<= lon .<= lonr[end]) .& (latr[1] .<= lat .<= latr[end])
    return sla[sel],slaf[sel],lon[sel],lat[sel],time[sel],id[sel]
end




lonr = [-7,37]
latr = [30,46]

product_id = "SEALEVEL_EUR_PHY_L3_MY_008_061"

basedir = expanduser("~/tmp/BlueCloud2026/Altimetry/")




username = ENV["CMEMS_USERNAME"]
password = ENV["CMEMS_PASSWORD"]

url = "ftp://my.cmems-du.eu/Core/" * product_id
download_level = 5

cd(basedir) do
    run(`wget --no-parent --recursive --level=$(download_level) -nH --cut-dirs=1  --user=$(username) --password=$(password) $(url)`)
end

#=

fnames = listfiles(basedir, extension = ".nc")



date = getdate.(fnames)


udates = unique(sort(date))

#udates = unique(sort(date))[1:20]

len = length(udates)

const T = Float32

sla = Vector{Vector{T}}(undef,len)
slaf = Vector{Vector{T}}(undef,len)
lon = Vector{Vector{T}}(undef,len)
lat = Vector{Vector{T}}(undef,len)
time = Vector{Vector{DateTime}}(undef,len)
id = Vector{Vector{Int64}}(undef,len)

#Threads.@threads for i in 1:len
for i in 1:len
    sel = findall(date .== udates[i])
    println("load $(sum(sel)) at $(udates[i])")

    sla[i],slaf[i],lon[i],lat[i],time[i],id[i] = load(fnames[sel],lonr,latr)
end


#=
jldopen(outname, "w") do file
    file[varname] = sla
    file[varname * "f"] = slaf
    file["lon"] = lon
    file["lat"] = lat
    file["time"] = time
    file["id"] = id
    file["dates"] = udates
end
=#






len = length.(sla);
sla = reduce(vcat,sla);
slaf = reduce(vcat,slaf);
lon = reduce(vcat,lon);
lat = reduce(vcat,lat);
time = reduce(vcat,time);
id = reduce(vcat,id);


ds = NCDataset(outname,"c")
#defVar(ds,"dtime",time,("time",); typename="dtime_type");
#defVar(ds,"sla",sla,("time",); typename="sla_type");
#defVar(ds,"lon",lon,("time",); typename="lon_type");
#defVar(ds,"lat",lat,("time",); typename="lat_type");
#defVar(ds,"id",id,("time",); typename="id_type");
#defVar(ds,"dtime",time,("time",); typename="dtime_type");

defVar(ds,"size",len,("track",); attrib = OrderedDict("sample_dimension" => "time"));
defVar(ds,"dates",DateTime.(udates),("track",))

defVar(ds,"sla",sla,("time",))
defVar(ds,"slaf",slaf,("time",))
defVar(ds,"lon",lon,("time",))
defVar(ds,"lat",lat,("time",))
defVar(ds,"id",id,("time",))
defVar(ds,"dtime",time,("time",), attrib = OrderedDict("long_name" => "time of measurement"))

close(ds)

=#
