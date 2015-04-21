import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace gl = "getLayer" at "getLayerLibrary.xqy";

import module namespace tk = "topK" at "topKLibrary.xqy";


 
osm_gml:_result2Osm(
  for-each(
        gl:getElementsByKeyword(.,"hotel"),
  tk:closestDistanceWrtElementByKeywords(.,?,"restaurant", 0.003)
     )/*       
  )