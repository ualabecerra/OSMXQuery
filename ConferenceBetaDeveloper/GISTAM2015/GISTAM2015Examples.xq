import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

(: Example 1 :)
(: Retrieve the schools and high schools close to Calzada de Castro :)

osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,("high school","school"))))

(: Example 2 :)
(: Retrieve the streets crossing Calzada de Castro and ending to Avenida Monstserrat
 street :)

let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro")))
return 
osm_gml:_result2Osm(
fn:filter($onewaysCrossing, osm:isEndingTo(?, osm:getOneWay(., "Avenida Nuestra Señora de Montserrat")))
) 

(: Example 3 :)
(: Retrieve the schools close to a street, wherein Calzada de Castro street ends :)
let $onewaysAllEndingTo :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isEndingTo(osm:getOneWay(., "Calle Calzada de Castro"),?))

return 
osm_gml:_result2Osm(
fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByOneWay(.,?)) , 
osm:searchTags(?,"school"))) 

(: Example 4 :)
(:              :)
osm_gml:_result2Osm(osm:intersectionQuery( 
   osm:unionQuery(rt:getLayerByName(.,"El Arbol"), rt:getLayerByName(.,"pharmacy")),
   rt:getLayerByName(.,"Calle Calzada de Castro")))
   
(: Query 5 :)
(:              :)
osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:furtherNorthWays(osm:getOneWay(., "Calle Calzada de Castro"),?))
) 

(: Query 6 :)

(:   
osm_gml:_result2Osm(
 fn:filter(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"),osm:searchTags(?,"building"))
  , osm:isInGeometry(osm:getOneWay(.,"Calle Calzada de Castro"),?)
) 
)
:)

(: Query 7 :)

(: 
osm_gml:_result2Osm(
   fn:filter(
  fn:filter(rt:getLayerByName(.,"El Arbol"),osm:searchTags(?,"building"))
  , osm:isInGeometry(osm:getOneWay(.,"El Arbol"),?)
) 
) 
:)

(: Query 8 :)

(: let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro")))
return 
 osm_gml:_result2Osm(
 fn:filter( 
  fn:filter(fn:for-each($onewaysCrossing, rt:getLayerByOneWay(.,?)), osm:searchTags(?,"building"))
   , osm:isInGeometry(osm:getOneWay(.,"Calle Calzada de Castro"),?)
)
) 
:)

(: Query 9 :)
(: fn:for-each(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:furtherNorthWays(osm:getOneWay(., "Calle Calzada de Castro"),?))
  , osm:getDistanceBetweenGeometries(?, osm:getOneWay(. ,"Calle Calzada de Castro")))
:)