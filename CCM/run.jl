using Pkg
Pkg.add(url="https://github.com/Alexander-Barth/CoastalCurrents.jl")

using CoastalCurrents
dirname = joinpath(dirname(pathof(CoastalCurrents)),"..","examples")

include(joinpath(dirname,"prep_altimetry.jl"))
