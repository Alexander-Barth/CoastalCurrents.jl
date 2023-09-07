using Downloads: download

altimetry_fname = expanduser("~/tmp/BlueCloud2026/Altimetry/all-sla.nc")
#altimetry_fname = expanduser("~/tmp/BlueCloud2026/Altimetry/all-sla-subset.nc")
varname = "sla"


lonr = [-7,37]
latr = [30,46]


dlon = dlat = 0.25

dlon = dlat = 0.25

lonr = -7:dlon:37
latr = 30:dlat:46

product_id = "SEALEVEL_EUR_PHY_L3_MY_008_061"

basedir = expanduser("~/tmp/BlueCloud2026/Altimetry/")

mkpath(basedir)

bathname = expanduser("~/tmp/BlueCloud2026/gebco_30sec_4.nc")
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

cred = load_netrc()

# get CMEMS credentials

# https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python
# https://web.archive.org/web/20230906115443/https://help.marine.copernicus.eu/en/articles/6135460-how-to-configure-a-simple-opendap-access-directly-in-python

username = cred["my.cmems-du.eu"]["login"]
password = cred["my.cmems-du.eu"]["password"]

nothing
