# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -all
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: Julia 1.9.3
#     language: julia
#     name: julia-1.9
# ---

# # Generate surface currents from drifter data

using Dates
using NCDatasets
using PhysOcean
using CoastalCurrents
using DIVAnd_HFRadar
using DIVAnd
using PyPlot

include("common.jl")


# +
#timerange = [DateTime(2020,1,1),DateTime(2020,12,31)]
#param = "NSCT"
# -

files = String[]
for (root, dirs, files2) in walkdir(drifter_dir)
    for file in files2
        push!(files,joinpath(root, file)) # add path to files
    end
end

fname = files[1]

ds = NCDataset(fname)

lon,lat,z,time,u,v = CoastalCurrents.loaddata(files);

speed = @. sqrt(u^2 + v^2);

good = isfinite.(u) .&& isfinite.(time) .&& isfinite.(lon) .&& (lonr[1] .<= lon .<= lonr[end]) .&& (latr[1] .<= lat .<= latr[end]) .&& speed .< 0.5;

(lon,lat,z,time,u,v) = map(d -> d[good],(lon,lat,z,time,u,v));

# @show length(lon)
# using PyPlot
# quiver(lon,lat,u,v)
# rg(z)


plt.hist2d(lon,lat,(lonr,latr),norm=matplotlib.colors.LogNorm())
colorbar(orientation="horizontal",label="count")
CoastalCurrents.Plotting.plotmap(bathname)
title("Data count per bins of $(step(lonr))° x $(step(latr))° ");



mask,(pm,pn),(xi,yi) = DIVAnd.domain(bathname,bathisglobal,lonr,latr)
hx, hy, h = DIVAnd.load_bath(bathname, bathisglobal, lonr, latr);

label = DIVAnd.floodfill(mask)
mask = label .== 1;


# pcolormesh(xi,yi,mask)

len = 50e3

robs = vcat(u,v)
robs = Float64.(nomissing(robs,NaN))
directionobs = vcat(fill(90,size(u)), fill(0,size(v)))
epsilon2 = 0.1
residual = zeros(size(robs))
g = 9.81;
g = 0;
x = [lon; lon]
y = [lat; lat]
eps2_boundary_constraint = -1
eps2_div_constraint = -1
#eps2_boundary_constraint = 1e-9
eps2_div_constraint = 1e+1
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
);

speedi = @. sqrt(uri^2 + vri^2)
clf(); q=quiver(xi,yi,uri,vri,speedi,scale=10)
quiverkey(q,0.1,0.3,1,"1 m/s")
xlim(-7,15)
ylim(35.,44.5)
#colorbar(orientation="vertical")
colorbar(orientation="horizontal")
title("average near-surface currents (2020), m/s")
#CoastalCurrents.Plotting.set_aspect_ratio()
#OceanPlot.plot_coastline()
CoastalCurrents.Plotting.plotmap(bathname)
#savefig(expanduser("~/Figures/bluecloud-drifter-vel-div-$(eps2_div_constraint).png"))


