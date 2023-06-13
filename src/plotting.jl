module Plotting
using Random

include("nc2leafletvelocity.jl")


const leaflet_init = Ref(false);

function setup()
#    if leaflet_init[]
#        return
    #    end
    @debug "Load leaflet and leaflet-velocity"
    display("text/javascript", """
var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'https://data-assimilation.net/upload/Alex/leaflet-velocity/demo2/leaflet.js';
    document.head.appendChild(script)
""")


    display("text/javascript", """
var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'https://data-assimilation.net/upload/Alex/leaflet-velocity/dist/leaflet-velocity.min.js';
    document.head.appendChild(script)
""")

    display("text/html","""<link rel="stylesheet" href="https://npmcdn.com/leaflet@1.1.0/dist/leaflet.css" />
<link rel="stylesheet" href="http://data-assimilation.net/upload/Alex/leaflet-velocity/dist/leaflet-velocity.min.css" />
<link rel="stylesheet" href="http://data-assimilation.net/upload/Alex/leaflet-velocity/demo2/demo.css" />
""");
#    leaflet_init[] = true;
end


function plot(lon,lat,u,v;
              reduce = 1,
              time = DateTime(2000,1,1),
              scale = 10,
              zoom = 5,
              center = (41,9),
              maxvelocity = 0.2,
              )

    setup();
    io = IOBuffer()
    nc2json(lon,lat,time,u,v,io; reduce = 1)
    str = String(take!(io))
    datastr = "data" * randstring(10);
    mapid = "map" * randstring(10);

    display("text/javascript","""window.$(datastr) = JSON.parse(`$(str)`);""");

    display("text/html","""<div id="$mapid" style="width: 800px; height: 400px;"></div>""")
    display("text/javascript","""
 var Esri_WorldImagery = L.tileLayer(
    "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    {
      attribution:
        "BlueCloud; Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, " +
        "AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community"
    }
  );

  var Esri_DarkGreyCanvas = L.tileLayer(
    "http://{s}.sm.mapstack.stamen.com/" +
      "(toner-lite,\$fff[difference],\$fff[@23],\$fff[hsl-saturation@20])/" +
      "{z}/{x}/{y}.png",
    {
      attribution:
        "BlueCloud; Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, " +
        "NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community"
    }
  );

  var baseLayers = {
    "Satellite": Esri_WorldImagery,
    "Grey Canvas": Esri_DarkGreyCanvas
  };

  var map = L.map("$mapid", {
    layers: [Esri_WorldImagery],
    scrollWheelZoom: false
  });

  var layerControl = L.control.layers(baseLayers);
  layerControl.addTo(map);
  map.setView([$(center[1]), $(center[2])], $(zoom));

  var velocityLayer = L.velocityLayer({
            displayValues: true,
            displayOptions: {
                velocityType: "GBR Water",
                displayPosition: "bottomleft",
                displayEmptyString: "No water data"
            },
            data: $(datastr),
            maxVelocity: $(maxvelocity),
            velocityScale: $(scale) // arbitrary default 0.005
        });

  layerControl.addOverlay(velocityLayer, name);
  velocityLayer.addTo(map);
""");
end

end
