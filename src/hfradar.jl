module HFRadar

#import CoastalCurrents
using NCDatasets
using PhysOcean
using Dates
using Statistics
using DataStructures


# function to load all data

function loaddata(fname::AbstractString);
    ds = NCDataset(fname);
    time = ds["TIME"][:];
   # time_qc = ds["TIME_QC"][:]

    lon = ds["LON"][:,:];
    lat = ds["LAT"][:,:];
  #  position_qc = ds["POSITION_QC"][:,:,:,:];
    
   
 #   z = ds["DEPH"][:]
 #   z_qc = ds["DEPH_QC"][:]
    
    rdva = ds["RDVA"][:,:,:,:];
    
    drva = ds["DRVA"][:,:,:,:];
        

    lon = mod.(lon .+ 180,360) .- 180   ;         #normalisation des données de longitude

  #  lon[.!good.(position_qc)] .= NaN;
  #  lat[.!good.(position_qc)] .= NaN;
  #  z[.!good.(z_qc)] .= NaN;
  #  time[.!good.(time_qc)] .= DateTime(9999,1,1);
  #  u[.!good.(u_qc)] .= NaN;
  #  v[.!good.(v_qc)] .= NaN;

    
    lonT = repeat(lon, size(rdva,4));
    latT = repeat(lat, size(rdva,4));
    time = repeat(reshape(time,(1,1,1,size(rdva,4))),inner=(size(lon,1), size(lon,2), 1, 1));
    
    
    
#    good(qc) = !ismissing(qc) && ((qc == 1) || (qc == 2))
    
#    lon[.!good.(position_qc)] .= NaN;   #471016728 valeurs avant le quality control
#    lat[.!good.(position_qc)] .= NaN;
    
 
    close(ds)
    return lonT[:],latT[:],time[:],rdva[:],drva[:];
end


function loaddata(files::AbstractVector{<:AbstractString}); #prend l'argument file, devant être un vecteur de string
    
    data = loaddata.(files);
    # concatenate all profiles
    lon = reduce(vcat,getindex.(data,1));
    lat = reduce(vcat,getindex.(data,2));
   # z = reduce(vcat,getindex.(data,3))
    time = reduce(vcat,getindex.(data,3));
    rdva = reduce(vcat,getindex.(data,4));
    drva = reduce(vcat,getindex.(data,5));
  # v = reduce(vcat,getindex.(data,6))

    return lon[:],lat[:],time[:],rdva[:],drva[:]
end




#################################DEUXIEME FONCTION POUR LES FICHIERS NON TRAITES


function loaddata2(fname::AbstractString)
    @show fname
    ds = NCDataset(fname)
    time = ds["TIME"][:]
   # time_qc = ds["TIME_QC"][:]

    lon = ds["LONGITUDE"][:];
    lat = ds["LATITUDE"][:];
  #  position_qc = ds["POSITION_QC"][:,:,:,:];
    
   
 #   z = ds["DEPH"][:]
 #   z_qc = ds["DEPH_QC"][:]
    
    EWCT = ds["EWCT"][:,:,:,:]
    
    NSCT = ds["NSCT"][:,:,:,:]
        

    lon = mod.(lon .+ 180,360) .- 180            #normalisation des données de longitude

  #  lon[.!good.(position_qc)] .= NaN;
  #  lat[.!good.(position_qc)] .= NaN;
  #  z[.!good.(z_qc)] .= NaN;
  #  time[.!good.(time_qc)] .= DateTime(9999,1,1);
  #  u[.!good.(u_qc)] .= NaN;
  #  v[.!good.(v_qc)] .= NaN;

    
    lonT = repeat(lon, size(EWCT,4));
    latT = repeat(lat, size(EWCT,4));
    time = repeat(reshape(time,(1,1,1,size(EWCT,4))),inner=(size(lon,1), size(lon,1), 1, 1));
    
    
    
#    good(qc) = !ismissing(qc) && ((qc == 1) || (qc == 2))
    
#    lon[.!good.(position_qc)] .= NaN;   #471016728 valeurs avant le quality control
#    lat[.!good.(position_qc)] .= NaN;
    
 
    close(ds)
    return lonT[:],latT[:],time[:],EWCT[:],NSCT[:]
end


function loaddata2(files::AbstractVector{<:AbstractString}) #prend l'argument file, devant être un vecteur de string
    @show files
    data = loaddata.(files);
    # concatenate all profiles
    lon = reduce(vcat,getindex.(data,1))
    lat = reduce(vcat,getindex.(data,2))
   # z = reduce(vcat,getindex.(data,3))
    time = reduce(vcat,getindex.(data,3))
    rdva = reduce(vcat,getindex.(data,4))
    drva = reduce(vcat,getindex.(data,5))
  # v = reduce(vcat,getindex.(data,6))

    return lon[:],lat[:],time[:],EWCT[:],NSCT[:]
end





end #end of module


#(71889,)  time
#(6552,)   lat
#(6552,)   lon
#(471016728,)  rdva 
#(471016728,)  drva

