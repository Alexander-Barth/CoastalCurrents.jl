using PhysOcean, Dates, NCDatasets, JLD2
using PhysOcean
using CoastalCurrents
using DIVAnd_HFRadar

username = ENV["CMEMS_USERNAME"]
password = ENV["CMEMS_PASSWORD"]

lonr = [-12, 22.]
latr = [30, 55.5]
timerange = [DateTime(2010,5,1),DateTime(2020,1,1)]

#lonr = [7.6, 12.2]
#latr = [42, 44.5]
timerange = [DateTime(2020,1,1),DateTime(2020,12,31)]
param = "NSCT"

indexURLs = ["ftp://my.cmems-du.eu/Core/INSITU_GLO_PHY_UV_DISCRETE_MY_013_044/cmems_obs-ins_glo_phy-cur_my_drifter_PT6H/index_history.txt"]

datadir = expanduser("~/Data/Blue-Cloud-2026/drifter")
mkpath(datadir)
basedir = datadir



#files = CMEMS.download(lonr,latr,timerange,param,username,password,basedir; indexURLs = indexURLs)

files = String[]
for (root, dirs, files2) in walkdir(basedir)
    for file in files2
        push!(files,joinpath(root, file)) # path to files
    end
end

fname = files[1]

ds = NCDataset(joinpath(basedir,fname))




lon,lat,z,time,u,v = CoastalCurrents.loaddata(files);

good = isfinite.(u) .&& isfinite.(time) .&& isfinite.(lon) .&& (lonr[1] .<= lon .<= lonr[end]) .&& (latr[1] .<= lat .<= latr[end])

(lon,lat,z,time,u,v) = map(d -> d[good],(lon,lat,z,time,u,v))

@show length(lon)
using PyPlot
quiver(lon,lat,u,v)
rg(z)



#=
function DIVAndrun_HFRadar(
    mask,h,pmn,xyi,xyobs,robs,directionobs,len,epsilon2;
    eps2_boundary_constraint = -1,
    eps2_div_constraint = -1,
    eps2_Coriolis_constraint = -1,
    f = 0.001,
    residual = zeros(size(robs)),
    g = 0.,
    ratio = 100,
    lenη = (000.0, 000.0, 24 * 60 * 60. * 10),
    maxit = 100000,
    tol = 1e-6,
)
=#
