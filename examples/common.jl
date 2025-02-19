using Downloads: download



# used varname
varname = "sla"

# Grid definition
lonmax = 37
lonmin = -7
latmax = 46
latmin = 30

# resolution
dlon = dlat = 0.25               # Resolution 
lonr = lonmin:dlon:lonmax        # -7 Gibraltar to 37 which is BlackSea east
latr = latmin:dlat:latmax        # 30 on Lybia to 46 onto the north of the Black Sea

product_id_altymetry = "SEALEVEL_EUR_PHY_L3_MY_008_061"        # Altimetry dataset
product_id_DRIFT_HFR = "INSITU_GLO_PHY_UV_DISCRETE_MY_014_033" # Drifters and HFRadar dataset


# Base Directory for Dataset

basedir = expanduser("~/tmp/BlueCloud2026") 


# Directories in basedir (~/tmp/BlueCloud2026)

altimetry_dir = joinpath(basedir,"Altimetry")
drifter_dir = joinpath(basedir,"Drifter")
hf_dir = joinpath(basedir,"HF") 


# File for altimetry : Variable used in "DATA_PREOARATION" to load altimetry dataset

altimetry_fname = joinpath(altimetry_dir,"all-sla.nc")
#altimetry_fname = joinpath(altimetrydir,"all-sla-subset.nc")

mkpath(basedir)        
mkpath(altimetry_dir)
mkpath(drifter_dir)
mkpath(hf_dir)



# Mask and bathymetry in basedir

bathname = joinpath(basedir,"gebco_30sec_4.nc")
bathisglobal = true

result_filename = "surface-currents.nc"

# Download of bathymetry if not present

if !isfile(bathname)
    @info "downloading $(basename(bathname))"
    download("https://dox.ulg.ac.be/index.php/s/RSwm4HPHImdZoQP/download",bathname)
end




# function to create ~/.netrc


function load_netrc(fname = expanduser("~/.netrc"))
    cred = Dict{String,Any}()
    machine = ""
    entry = Dict()

    for line in eachline(fname)
        if startswith(line,"#") || strip(line) == ""
            continue
        end

        key,value = split(line,limit=2)
        if key == "machine"
            if machine !== ""
                cred[machine] = entry
                empty!(entry)
            end
            machine = value
        elseif key in ("login","password","account","macdef")
            entry[key] = value
        end
    end

    if machine !== ""
        cred[machine] = entry
    end

    return cred
end

#if haskey(ENV,"CMEMS_USERNAME") && haskey(ENV,"CMEMS_PASSWORD")
#    username = ENV["CMEMS_USERNAME"]
#    password = ENV["CMEMS_PASSWORD"]
#else
#    cred = load_netrc()

    # get CMEMS credentials

    # https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python
    # https://web.archive.org/web/20230906115443/https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python

#    username = cred["my.cmems-du.eu"]["login"]
#    password = cred["my.cmems-du.eu"]["password"]
#end

nothing
