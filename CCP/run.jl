using Pkg
Pkg.add(url="https://github.com/Alexander-Barth/CoastalCurrents.jl")

using CoastalCurrents
pathname = joinpath(dirname(pathof(CoastalCurrents)),"..","examples")

include(joinpath(pathname,"prep_altimetry.jl"))
