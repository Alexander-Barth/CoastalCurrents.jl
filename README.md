# CoastalCurrents.jl

Contribution to the [BlueCloud 2026](https://blue-cloud.org/) project for the virtual lab [Coastal currents from observations](https://blue-cloud.d4science.org/group/coastalcurrentsfromobservations).
Here is a direct link to the [JupyterHub instance](https://jupyterhub.d4science.org/hub/oauth_login?context=%2Fd4science.research-infrastructures.eu%2FD4OS%2FCoastalCurrentsFromObservations).

You will need to have [Julia 1.9](https://julialang.org/downloads/) installed. Start julia and issue the following command:

```julia
using Pkg
Pkg.add("https://github.com/Alexander-Barth/CoastalCurrents.jl")
```



# CCP

Create and update the docker container used as CCP runtime:

``` bash
sudo docker build  --tag abarth/coastal-currents-docker:$(date --utc +%Y-%m-%dT%H%M)  --tag abarth/coastal-currents-docker:latest .
docker push abarth/coastal-currents-docker
```


# Links

https://blue-cloud.d4science.org/group/bluecloud-gateway
https://blue-cloud.d4science.org/group/blue-cloudtraininglab
https://blue-cloud.d4science.org/group/blue-cloudtraininglab/ccp-method-execution
https://ccp-ct1.d4science.org/docs/index.html
