using Dates
using Interpolations
using JSON3
using NCDatasets

function dd(lon,lat,u,parameterNumberName,parameterNumber,refTime)
    return Dict{String,Any}(
        "header" => Dict{String,Any}(
            "la1"                 => lat[1],
#            "la2"                 => lat[end],
            "lo1"                 => lon[1],
#            "lo2"                 => lon[end],
            "dx"                  => lon[2,2] - lon[1,1],
            "dy"                  => -(lat[2,2] - lat[1,1]),
            "parameterNumber"     => parameterNumber,
            "parameterNumberName" => parameterNumberName,
            "parameterCategory"   => 2,
            "refTime"             => refTime,
            "nx"                  => size(u,1),
            "ny"                  => size(u,2),
            "parameterUnit"       => "m.s-1",
        ),
        "data" => vec(replace(u,NaN => 0))
    )
end



function nc2json(lon,lat,time,u,v,f::IO; reduce = 1)
#    @assert all(lon[1,:] .== lon[1,1])
#    @assert all(lat[:,1] .== lat[1,1])

    i = 1:reduce:size(u,1)
    j = 1:reduce:size(u,2)

    lon = lon[i,j]
    lat = lat[i,j]
    u = u[i,j]
    v = v[i,j]

    @debug "size of velocity" size(u) size(v)
    refTime = Dates.format(time,"yyyy-mm-dd HH:MM:SS")
    data = [dd(lon,lat,u,"Eastward current",2,refTime), dd(lon,lat,v,"Northward current",3,refTime)]


    JSON3.write(f, data)
end

function nc2json(lon,lat,time,u,v,outfname::AbstractString; reduce = 1)
    open(outfname,"w") do f
        nc2json(lon,lat,time,u,v,f; reduce = reduce)
    end
end

function nc2json(fname::AbstractString,varname,gridname,outfname; reduce = 1, ndepth = 1, ntime = 1)

    ds = Dataset(fname);

    ncu = ds[varname[1]]
    ncv = ds[varname[2]]

    lon_u = nomissing(NCDatasets.coord(ncu,"longitude")[:,:])
    lat_u = nomissing(NCDatasets.coord(ncu,"latitude")[:,:])

    lon_v = nomissing(NCDatasets.coord(ncv,"longitude")[:,:])
    lat_v = nomissing(NCDatasets.coord(ncv,"latitude")[:,:])

    time = NCDatasets.coord(ncu,"time")[ntime]
    @show time

    lon = nomissing(ds[gridname[1]][:,:])
    lat = nomissing(ds[gridname[2]][:,:])

    itp_u = LinearInterpolation((lon_u[:,1],lat_u[1,:]),nomissing(ncu[:,:,ndepth,ntime],NaN),extrapolation_bc = NaN);
    itp_v = LinearInterpolation((lon_v[:,1],lat_v[1,:]),nomissing(ncv[:,:,ndepth,ntime],NaN),extrapolation_bc = NaN);

    u = itp_u.(lon,lat);
    v = itp_v.(lon,lat);


    nc2json(lon,lat,time,u,v,outfname; reduce = reduce)

    close(ds)
end

#=

fname = "/home/abarth/tmp/champs_corse_BE201706_surface_20170601.nc"
outfname = "/home/abarth/src/leaflet-velocity/demo2/model-MARS.json"
varname = ("UZ","VZ")
gridname = ("longitude","latitude")
ndepth = 1
ntime = 1



nc2json(fname,varname,gridname,outfname;
        ndepth = ndepth,
        ntime = ntime
)

fname = "/mnt/data1/abarth/work/LS2v/Calvi-2015-u3hadv-vega/Calvi-2015-u3hadv/ocean_his.nc"
outfname = "/home/abarth/src/leaflet-velocity/demo2/model-ROMS.json"
varname = ("u","v")
gridname = ("lon_rho","lat_rho")
ndepth = 32
ntime = 3

nc2json(fname,varname,gridname,outfname;
        ndepth = ndepth,
        ntime = ntime
)


fname = "/mnt/data1/abarth/work/LS2v/Calvi-2015-u3hadv-vega/Calvi-2015-u3hadv/ocean_nest_his.nc"
outfname = "/home/abarth/src/leaflet-velocity/demo2/model-ROMS-nest.json"
varname = ("u","v")
gridname = ("lon_rho","lat_rho")
ndepth = 32
ntime = 3

nc2json(fname,varname,gridname,outfname;
        ndepth = ndepth,
        ntime = ntime
)



fname = "/mnt/data1/abarth/work/LS2v/Calvi-2015-u3hadv-vega/Calvi-2015-u3hadv/ocean_nest_calvi_his.nc"
outfname = "/home/abarth/src/leaflet-velocity/demo2/model-ROMS-nest_calvi.json"
varname = ("u","v")
gridname = ("lon_rho","lat_rho")
ndepth = 32
ntime = 3

nc2json(fname,varname,gridname,outfname;
        ndepth = ndepth,
        ntime = ntime
)

=#
