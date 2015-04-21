import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

import module namespace osm_solap = "osm_solap" at "solapOSMLibrary.xqy"; 

let $restaurants := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
           osm:searchTags(?,"restaurant"))                  


return

osm_solap:metricBottomCount($restaurants,"osm:getDistance",3) 

