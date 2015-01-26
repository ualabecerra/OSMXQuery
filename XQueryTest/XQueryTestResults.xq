import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

**************************************************************

(: Query 1 :)
(: Dame todos los colegios e institutos cerca de Calzada de Castro :)

(: osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro",0.001), 
osm:searchTags(?,("high school","school")))
)
:)

**************************************************************

(: Query 2 :)
(: Dame todas las calles que cruzan Calzada de Castro y terminan en 
   Avenida Nuestra Señora de Monsterrat :)

(:
  let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isCrossing(?, rt:getElementByName(., "Calle Calzada de Castro")))
return 
osm_gml:_result2Osm(
fn:filter($onewaysCrossing, osm:isEnding(?, rt:getElementByName(., "Avenida Nuestra Señora de Montserrat")))
) 
:)

(: Versión indice nuevo con distancia :)

(: osm_gml:_result2Osm(
fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro",0), osm:isEnding(?, 
          rt:getElementByName(., "Avenida Nuestra Señora de Montserrat")))
) 
:)

**************************************************************

(: Query 3 :)
(: Dame todos los colegios proximos a una calle que finaliza en Calzada de Castro :)

(: 
  let $onewaysAllEndingTo :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isEndingTo(rt:getElementByName(., "Calle Calzada de Castro"),?))

return 
osm_gml:_result2Osm(
fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByElement(.,?)) , osm:searchTags(?,"school"))
) 
:)

(: Versión indice nuevo con distancia :)
 
(: let $onewaysAllEndingTo :=  fn:filter(
   rt:getLayerByName(.,"Calle Calzada de Castro", 0.001), 
   osm:isEndingTo(rt:getElementByName(., "Calle Calzada de Castro"),?))

return 
osm_gml:_result2Osm(
fn:filter(
  fn:for-each($onewaysAllEndingTo, rt:getLayerByElement(.,?,0.001)) , 
  osm:searchTags(?,"school"))
) :)

**************************************************************

(: Query 4 :)
(: Dame todas las calles en las que hay una farmacia o un Supermercado El Arbol
   proximas a Calzada de Castro :)

(:
  osm_gml:_result2Osm(
  osm:intersectionQuery( 
   osm:unionQuery(rt:getLayerByName(.,"Maxi Dia"), rt:getLayerByName(.,"pharmacy")),
   rt:getLayerByName(.,"Calle Calzada de Castro"))
) 
:)

(: Versión indice nuevo con distancia :)

(: osm_gml:_result2Osm(
  osm:intersectionQuery( 
   osm:unionQuery(rt:getLayerByName(.,"El Arbol", 0.001), 
                  rt:getLayerByName(.,"pharmacy", 0.001)),
   rt:getLayerByName(.,"Calle Calzada de Castro", 0.001))
)
:)

**************************************************************

(: Query 5 :)
(: Dame todas las calles que están más el norte de Calzada de Castro :)

(:
  osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
  osm:furtherNorthWays(rt:getElementByName(., "Calle Calzada de Castro"),?))
) 
:)

(: Versión indice nuevo con distancia :)

(: osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro", 0.001), 
  osm:furtherNorthWays(rt:getElementByName(., "Calle Calzada de Castro"),?))
)
:)

**************************************************************

(: Query 6 :)
(: Dame todos los edificios próximos a Calzada de Castro :)

(: Versión indice nuevo con distancia :)

(:
osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro",0.001) , osm:searchTags(?,"building")))
:)

**************************************************************

(: Query 7 :)
(: Dame todos los edificios proximos a un supermercado El Arbol :)

(:
osm_gml:_result2Osm(
   fn:filter(
  fn:filter(rt:getLayerByName(.,"El Arbol"), osm:searchTags(?,"building"))
  , osm:isIn(rt:getElementByName(.,"El Arbol"),?)
) 
) 
:)

(: Versión indice nuevo con distancia :)

(: osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"El Arbol", 0.001), osm:searchTags(?,"building"))
)
:)

**************************************************************

(: Query 8 :)
(: Dame todos los edificios que hay en cruces de Calzada de Castro :)

(:
let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isCrossing(?, rt:getElementByName(., "Calle Calzada de Castro")))
return 
 osm_gml:_result2Osm(
 fn:filter( 
  fn:filter(fn:for-each($onewaysCrossing, rt:getLayerByElement(.,?)), 
  osm:searchTags(?,"building"))
   , osm:isIn(rt:getElementByName(.,"Calle Calzada de Castro"),?)
)
) 
:)

(: Versión mejorada de los edificios que hay en cruces de Calzada de Castro:)

(: let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:isCrossing(?, rt:getElementByName(., "Calle Calzada de Castro")))

let $intersectionPoints :=  fn:for-each($onewaysCrossing, 
     osm:intersectionPoint(?,rt:getElementByName(.,"Calle Calzada de Castro")))

return 
osm_gml:_result2Osm(  
    fn:filter(fn:filter(fn:for-each($intersectionPoints, rt:getLayerByElement(.,?)),
           osm:searchTags(?,"building")),
           osm:isIn(?,rt:getElementByName(.,"Calle Calzada de Castro")))
)             
:) 

(: Versión indice nuevo con distancia :)

(: 
let $intersectionPoints :=  
    fn:for-each(
            rt:getLayerByName(.,"Calle Calzada de Castro", 0), 
            osm:intersectionPoint(?,rt:getElementByName(.,"Calle Calzada de Castro")))

return 
 osm_gml:_result2Osm(  
      fn:filter(
          fn:for-each($intersectionPoints, rt:getLayerByElement(.,?,0.001)),
          osm:searchTags(?,"building"))
)
:)

**************************************************************

(: Query 9 :)
(: Dame las calles más al norte de Calzada de Castro ordenadas por distancias :)

(:
 fn:for-each(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
 osm:furtherNorthWays(rt:getElementByName(., "Calle Calzada de Castro"),?))
  , osm:getDistance(?, rt:getElementByName(. ,"Calle Calzada de Castro")))
:)

(: Versión indice nuevo con distancia :)

(: 
  for $oneway in 
      fn:for-each(fn:filter(
             rt:getLayerByName(.,"Calle Calzada de Castro", 0.001), 
             osm:furtherNorthWays(rt:getElementByName(., "Calle Calzada de Castro"),?))
      ,
      osm:addTag(?, "distance", osm:getDistance(?, 
                 rt:getElementByName(. ,"Calle Calzada de Castro")))
 )
 order by $oneway/tag/@distance
 return osm_gml:_result2Osm($oneway[1])
:)

**************************************************************

(: Query 10 :)
(: Dame las calles cercanas a farmacias :)

(:
osm_gml:_result2Osm(fn:for-each(rt:getElementsByKeyword(.,"pharmacy"), rt:getLayerByElement(., ?, 0.01))
)
:)

**************************************************************

(: Query 11 :)
(: Dame las calles cercanas a zonas de ocio :)

(: declare function local:amenitySite($x){
  count(fn:filter($x, osm:searchTags(?,("bar", "restaurant")))) >= 3
};
 
 osm_gml:_result2Osm(
    fn:filter(
      fn:for-each(rt:getElementsByKeyword(.,"amenity"), rt:getLayerByElement(.,?,0.01))
      ,
      local:amenitySite(?)
    )
)
:)

**************************************************************

(: Query 12 :)
(: Dame los hoteles cercanos a zonas de ocio :)

(: declare function local:amenitySite($x){
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
:)

**************************************************************

(: Query 13 :)
(: Dame la zona donde hay más hoteles :)

(: 
for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"amenity"), 
                   rt:getLayerByElement(.,?,0.001)))
       ,
       osm:addTag(?, "numHotels", 
             count(fn:filter(?, osm:searchOneTag(?,"hotel"))))
        ) 
 order by $oneLayer/tag/@numHotels
 return 
     osm_gml:_result2Osm($oneLayer[1])  
:)