# CoastalCurrents.jl

Contribution to the [BlueCloud 2026](https://blue-cloud.org/) project for the virtual lab "Coastal currents from observations".

You will need to have [Julia 1.9](https://julialang.org/downloads/) installed. Start julia and issue the following command:


## Installation

```julia
using Pkg
Pkg.add("https://github.com/Alexander-Barth/CoastalCurrents.jl")
```


```bash
pip install copernicusmarine
```


## Test download

Using a shell command:

```bash
# https://help.marine.copernicus.eu/en/articles/8632322-copernicus-marine-toolbox-troubleshoots
export COPERNICUSMARINE_CACHE_DIRECTORY=/tmp
copernicusmarine get --dataset-id cmems_obs-sl_eur_phy-ssh_my_al-l3-duacs_PT1S
```

Using julia:

```julia
ENV["COPERNICUSMARINE_CACHE_DIRECTORY"]="/tmp"
run(pipeline(`yes`,`copernicusmarine get --dataset-id cmems_obs-sl_eur_phy-ssh_my_al-l3-duacs_PT1S`))
```
