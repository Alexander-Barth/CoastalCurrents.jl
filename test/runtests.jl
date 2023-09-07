using Test
using CoastalCurrents
using CoastalCurrents.Altimetry: perp_velocity

@testset "Altimetry" begin
    #=



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



    lon = [1,0]
    lat = [-51,-50]
    adt = [0, 1]

    lonc,latc,u,v = perp_velocity(lon,lat,adt)
    @test u[1] > 0
    @test v[1] > 0
end
