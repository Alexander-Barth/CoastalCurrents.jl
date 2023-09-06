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
