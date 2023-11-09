# executed in docker image abarth/coastal-currents-docker

using CoastalCurrents
pathname = joinpath(dirname(pathof(CoastalCurrents)),"..","examples")

include(joinpath(pathname,"prep_altimetry.jl"))
