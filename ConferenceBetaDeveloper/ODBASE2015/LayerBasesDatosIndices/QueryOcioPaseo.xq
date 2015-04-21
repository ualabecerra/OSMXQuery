import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

(:  declare function local:amenitySite($x){
  count(fn:filter($x, osm:searchTags(?,("restaurant", "hotel", "theatre", "bar")))) >= 3
};
 
 osm_gml:_result2Osm(
    fn:filter(
      fn:for-each(rt:getElementsByKeyword(.,"hotel"), rt:getLayerByElement(.,?,0.001))
      ,
      local:amenitySite(?)
    )
) :)

 declare function local:amenitySite($x){

   count(fn:filter($x/*,osm:searchTags(?,("restaurant", "bar")))) >= 1

 };

declare function local:createLayer($x){
  <layer>
  {rt:getLayerByElement(collection(), $x ,0.001)}
  </layer>
};

osm_gml:_result2Osm(      fn:filter(
          fn:for-each(rt:getElementsByKeyword(.,"hotel"), local:createLayer(?)),
          
          local:amenitySite(?))/*
      )