using NCDatasets
using CoastalCurrents

include("common.jl")

ds = NCDataset(result_filename)

n = 1
xi = ds["lon"][:]
yi = ds["lat"][:]
time = ds["time"][n]
uri = ds["u"][:,:,n]
vri = ds["v"][:,:,n]


CoastalCurrents.nc2json(xi,yi,time,uri,vri,"/tmp/foo.json"; reduce = 1)
