import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"leisure"), 
                   rt:getLayerByElement(.,?,0.001)))
       ,
       osm:addTag(?, "numHotels", 
             count(fn:filter(?, osm:searchOneTag(?,"hotel"))))
        ) 
 order by $oneLayer/tag/@numHotels
 return 
     osm_gml:_result2Osm($oneLayer[1]) 