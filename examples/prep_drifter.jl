# ---
# jupyter:
#   jupytext:
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

# # Download drifter data

# + tags=[]
using Dates
using NCDatasets
using PhysOcean
using CoastalCurrents
using DIVAnd_HFRadar
using DIVAnd
using PyPlot

# + tags=[]
include("common.jl")
# -


# Spatial domain defined in `common.jl`, longitude (`lonr`) and latitude (`latr`) (min:step:max)

# + tags=[]
lonr

# + tags=[]
latr

# + tags=[]
timerange = [DateTime(2020,1,1),DateTime(2020,12,31)]
param = "NSCT"

# + tags=[]
indexURLs = ["ftp://my.cmems-du.eu/Core/INSITU_GLO_PHY_UV_DISCRETE_MY_013_044/cmems_obs-ins_glo_phy-cur_my_drifter_PT6H/index_history.txt"]

# + tags=[]
files = CMEMS.download(lonr,latr,timerange,param,username,password,drifter_dir; indexURLs = indexURLs)
# -


