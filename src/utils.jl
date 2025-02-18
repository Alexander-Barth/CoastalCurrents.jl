function listfiles(topdir = "."; extension = "")
    list = String[]

    for (root,dirs,files) in walkdir(topdir)
        for file in files
            if length(extension) == 0
                push!(list, joinpath(root, file))
            else
                if endswith(file,extension)
                    push!(list, joinpath(root, file))
                end
            end
        end
    end
    return list
end

function save(result_filename,(lon,lat,time),(uri,vri)) #result : nom inventé
    isfile(result_filename) && rm(result_filename)

    NCDataset(result_filename,"c") do ds

        defVar(ds,"lon",lon,("lon",),attrib = OrderedDict(
            "long_name" => "longitude",
            "units" => "degrees_east",
            "standard_name" => "longitude"))

        defVar(ds,"lat",lat,("lat",),attrib = OrderedDict(
            "long_name" => "latitude",
            "units" => "degrees_north",
            "standard_name" => "latitude"))


        defVar(ds,"time",time,("time",),
               attrib = OrderedDict(
                   "standard_name" => "time",
                   "units" => "days since 1950-01-01 00:00:00",
               ))

        defVar(ds,"u",uri,("lon","lat","time"),attrib = OrderedDict(
            "long_name" => "zonal velocity",
            "units" => "m/s",
            "standard_name" => "eastward_sea_water_velocity"))

        defVar(ds,"v",vri,("lon","lat","time"),attrib = OrderedDict(
            "long_name" => "meridional velocity",
            "units" => "m/s",
            "standard_name" => "northward_sea_water_velocity"))

        ds.attrib["Conventions"] = "CF-1.10"

    end

    return nothing
end
