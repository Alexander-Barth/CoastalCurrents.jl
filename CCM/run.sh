
julia <<EOF
using Pkg
Pkg.add("https://github.com/Alexander-Barth/CoastalCurrents.jl")

using CoastalCurrents
@show pathof(CoastalCurrents)
EOF
