# executed in docker image abarth/coastal-currents-docker

using CoastalCurrents
pathname = joinpath(dirname(pathof(CoastalCurrents)),"..","examples")

include(joinpath(pathname,"prep_altimetry.jl"))
include(joinpath(pathname,"prep_drifter.jl"))

include(joinpath(pathname,"currents_altimetry.jl"))
include(joinpath(pathname,"currents_drifter.jl"))
