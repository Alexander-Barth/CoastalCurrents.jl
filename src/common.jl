
altimetry_fname = expanduser("~/tmp/BlueCloud2026/Altimetry/all-sla.nc")
varname = "sla"


lonr = [-7,37]
latr = [30,46]


dlon = dlat = 0.25
lonr = -7:dlon:37
latr = 30:dlat:46

product_id = "SEALEVEL_EUR_PHY_L3_MY_008_061"

basedir = expanduser("~/tmp/BlueCloud2026/Altimetry/")


username = ENV["CMEMS_USERNAME"]
password = ENV["CMEMS_PASSWORD"]
