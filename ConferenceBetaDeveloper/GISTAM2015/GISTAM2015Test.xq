import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,("high school","school"))))
 

