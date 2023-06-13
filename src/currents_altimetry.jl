using DIVAnd_HFRadar
using PhysOcean
using GeoMapping
using OceanPlot
using NCDatasets
using Dates
using Test
using DIVAnd

include("common.jl")


ds = NCDataset(altimetry_fname)
mdt = ds["mdt"][:]
sla = ds["slaf"][:]
lon = ds["lon"][:]
lat = ds["lat"][:]
time = ds["time"][:]
id = ds["id"][:]

len = ds["len"][:]

close(ds)

adt = mdt + sla



#figure();scatter(lon,lat,10,id)
#figure();
#scatter(lon,lat,10,adt);
#OceanPlot.set_aspect_ratio()


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



scale = 50
scale = 5


sel = 1:100
len = len[sel]

lon = lon[1:sum(len)]
lat = lat[1:sum(len)]
adt = adt[1:sum(len)]
time = time[1:sum(len)]

lenc = len .- 1

lona = Vector{Float64}(undef,sum(lenc))
lata = Vector{Float64}(undef,sum(lenc))
ua = Vector{Float64}(undef,sum(lenc))
va = Vector{Float64}(undef,sum(lenc))
timea = Vector{DateTime}(undef,sum(lenc))



k = 0
kc = 0

# loop for every track
for j = 1:length(len)
    global k
    global kc
    local i
    local timec
    local latc
    i = k .+ (1:len[j])
    ic = kc .+ (1:lenc[j])

    # loop along track
    for l = 1:lenc[j]
        lona[kc+l] = (lon[k+l+1]+lon[k+l])/2
        lata[kc+l] = (lat[k+l+1]+lat[k+l])/2

        timea[kc+l] = Dates.epochms2datetime(
            (Dates.datetime2epochms.(time[k+l+1]) +
                Dates.datetime2epochms.(time[k+l])) ÷ 2)
    end

    perp_velocity!(
        (@view lon[i]),(@view lat[i]),(@view adt[i]),
        (@view ua[ic]),(@view va[ic]))

    #scatter(lon[i],lat[i],10,adt[i])
    k += len[j]
    kc += lenc[j]
end


r = 1:1:length(ua)

#=
clf()
scatter(lon,lat,10,adt,vmin=-0.1,vmax = 0.08,cmap="jet"); colorbar()
quiver(lona[r],lata[r],ua[r],va[r],scale=scale,lw = 0.1)
#xlim((2.5832958255391247, 5.08659455171254))
#ylim((36.03972058860369, 38.84928070740686))

#OceanPlot.plot_coastline("f")
xlim((22.25885640558503, 27.75667790863112))
ylim((31.704241622526148, 37.93893180755805))

OceanPlot.plotmap()
OceanPlot.set_aspect_ratio()
savefig(expanduser("~/Figures/altimetry_currents_$(timea[1]).png"))
=#



robs = sqrt.(ua.^2 + va.^2)
len = 150e3

# directionobs angle in degree relative to North
# see DIVAndrun_HFRadar
directionobs = atand.(ua,va)


@test ua[1] ≈ robs[1]*sind(directionobs[1])
@test va[1] ≈ robs[1]*cosd(directionobs[1])



bathname = expanduser("~/Data/DivaData/Global/gebco_30sec_4.nc")
bathisglobal = true



mask,(pm,pn),(xi,yi) = DIVAnd.domain(bathname,bathisglobal,lonr,latr)
hx, hy, h = DIVAnd.load_bath(bathname, bathisglobal, lonr, latr)


g = 0;
x = lona
y = lata


valid = isfinite.(robs)
x = lona[valid]
y = lata[valid]
robs = robs[valid]
directionobs = directionobs[valid]



epsilon2 = 2.
eps2_boundary_constraint = -1
eps2_div_constraint = -1
#eps2_boundary_constraint = 1e-9
eps2_div_constraint = 1e+1
eps2_div_constraint = 1

#figure()
uri,vri,ηi = DIVAndrun_HFRadar(
    mask,h,(pm,pn),(xi,yi),(x,y),robs,directionobs,len,epsilon2;
    eps2_boundary_constraint = eps2_boundary_constraint,
    eps2_div_constraint = eps2_div_constraint,
    # eps2_Coriolis_constraint = -1,
    # f = 0.001,
    # residual = residual,
    # g = g,
    # ratio = 100,
    # lenη = (000.0, 000.0, 24 * 60 * 60. * 10),
    # maxit = 100000,
    # tol = 1e-6,
)

#=
color = sqrt.(uri.^2 + vri.^2)

using PyPlot
clf()
r = CartesianIndices(( 1:2:size(mask,1) ,1:2:size(mask,2)))
r = CartesianIndices(( 1:1:size(mask,1) ,1:1:size(mask,2)))
quiver(xi[r],yi[r],uri[r],vri[r],color[r],cmap="jet")
colorbar(orientation="horizontal")
OceanPlot.plotmap()
OceanPlot.set_aspect_ratio()
title("surface current " * join(Dates.format.((minimum(timea),maximum(timea)),"yyyy-mm-dd")," - "))
savefig(expanduser("~/Figures/altimetry_currents_DIVAnd.png"),dpi=300)





clf()
r = CartesianIndices(( 1:1:size(mask,1) ,1:1:size(mask,2)))
quiver(xi[r],yi[r],uri[r],vri[r],color[r],cmap="jet",scale=2)
xlim(1.4689516128929263, 11)
ylim(38., 44.25205736596321)
colorbar(orientation="horizontal")
OceanPlot.plotmap()
OceanPlot.set_aspect_ratio()
title("surface current " * join(Dates.format.((minimum(timea),maximum(timea)),"yyyy-mm-dd")," - "))
savefig(expanduser("~/Figures/altimetry_currents_DIVAnd_zoom.png"),dpi=300)
=#



#=
lon = [0,1]
lat = [50,50]
adt = [0, 1]

perp_velocity(lon,lat,adt)



lon = [0,1]
lat = [50,51]
adt = [0, 1]

lonc,latc,u,v = perp_velocity(lon,lat,adt)
@test u[1] < 0
@test v[1] > 0


lon = [1,0]
lat = [50,51]
adt = [0, 1]

lonc,latc,u,v = perp_velocity(lon,lat,adt)
@test u[1] < 0
@test v[1] < 0

lon = [1,0]
lat = [50,51]
adt = [1, 0]

lonc,latc,u,v = perp_velocity(lon,lat,adt)
@test u[1] > 0
@test v[1] > 0

@show perp_velocity(lon,lat,adt)
@show perp_velocity(reverse(lon),reverse(lat),reverse(adt))



lon = [1,0]
lat = [-51,-50]
adt = [0, 1]

lonc,latc,u,v = perp_velocity(lon,lat,adt)
@test u[1] > 0
@test v[1] > 0

=#



#=


    * (i+1)



    * (i)

=#




#=

(adt[i+1] - adt[i])
=#
