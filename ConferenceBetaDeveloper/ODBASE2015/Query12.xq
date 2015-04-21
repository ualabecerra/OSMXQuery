import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

declare function local:amenitySite($x){
  count(fn:filter($x, osm:searchTags(?,("bar", "restaurant")))) >= 3
};
 
 osm_gml:_result2Osm(
   fn:filter( 
    fn:filter(
      fn:for-each(rt:getElementsByKeyword(.,"amenity"), rt:getLayerByElement(.,?,0.01))
      ,
      local:amenitySite(?)
    ),
    osm:searchOneTag(?,"hotel"))
)