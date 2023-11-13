using Downloads: download

varname = "sla"

dlon = dlat = 0.25
lonr = -7:dlon:37
latr = 30:dlat:46

product_id = "SEALEVEL_EUR_PHY_L3_MY_008_061"

basedir = expanduser("~/tmp/BlueCloud2026")

altimetry_dir = joinpath(basedir,"Altimetry")
drifter_dir = joinpath(basedir,"Drifter")

altimetry_fname = joinpath(altimetry_dir,"all-sla.nc")
#altimetry_fname = joinpath(altimetrydir,"all-sla-subset.nc")

mkpath(basedir)
mkpath(altimetry_dir)
mkpath(drifter_dir)

bathname = joinpath(basedir,"gebco_30sec_4.nc")
bathisglobal = true

result_filename = "surface-currents.nc"

if !isfile(bathname)
    @info "downloading $(basename(bathname))"
    download("https://dox.ulg.ac.be/index.php/s/RSwm4HPHImdZoQP/download",bathname)
end


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

if haskey(ENV,"CMEMS_USERNAME") && haskey(ENV,"CMEMS_PASSWORD")
    username = ENV["CMEMS_USERNAME"]
    password = ENV["CMEMS_PASSWORD"]
else
    cred = load_netrc()

    # get CMEMS credentials

    # https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python
    # https://web.archive.org/web/20230906115443/https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python

    username = cred["my.cmems-du.eu"]["login"]
    password = cred["my.cmems-du.eu"]["password"]
end

nothing
