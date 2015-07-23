import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

import module namespace osm_aggr = "osm_aggr" at "OSMAggregationLibrary.xqy";

**************************************************************

(: Example 1 :)
(: Dame todas las calles que están más el norte de Calzada de Castro :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer:= rt:getLayerByName(.,"Calle Calzada de Castro", 0.001)
return 
 fn:filter(fn:filter($referenceLayer, osm:furtherNorthWays($referenceWay,?)), 
           osm:searchKeyword(?,"highway"))
:)

**************************************************************

(: Example 2 :)
(: Dame todas las calles que cruzan Calzada de Castro y terminan en 
   Avenida Nuestra Señora de Monsterrat :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0),
    $onewaysCrossing := fn:filter($referenceLayer, 
                        osm:isCrossing(?, $referenceWay))
return
fn:filter($onewaysCrossing,osm:isEndingTo(?,
    rt:getElementByName(., "Avenida Nuestra Señora de Montserrat"))) 
:)

**************************************************************

(: Example 3 :)
(: Dame todos los colegios proximos a una calle que finaliza en Calzada de Castro :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro", 0),
    $onewaysAllEndingTo := fn:filter($referenceLayer, 
                           osm:isEndingTo($referenceWay,?))
return
fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByElement(.,?,0.001)), 
osm:searchKeyword(?,"school"))
:)

**************************************************************

(: Example 4 :)
(: Dame todas las calles en las que hay una farmacia o un Supermercado El Arbol
   proximas a Calzada de Castro :)

(: 
osm:intersectionQuery( 
   osm:unionQuery(rt:getLayerByName(.,"El Arbol", 0.001), 
                  rt:getLayerByName(.,"pharmacy", 0.001)),
   rt:getLayerByName(.,"Calle Calzada de Castro", 0.001))
:)

**************************************************************

(: Example 5 :)
(: Dame todos los edificios que hay en cruces de Calzada de Castro :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0),
    $onewaysCrossing := fn:filter($referenceLayer, 
                        osm:isCrossing(?, $referenceWay)),
    $intersectionPoints := fn:for-each($onewaysCrossing, 
                           osm:intersectionPoint(?,$referenceWay))
return 
fn:filter(
   fn:for-each($intersectionPoints, rt:getLayerByElement(.,?,0.001)),
   osm:searchKeyword(?,"building"))
:)

**************************************************************

(: Example 6 :)
(: Dame todos los colegios e institutos cerca de Calzada de Castro :)

(:
let $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0.001)
return 
 fn:filter($referenceLayer,osm:searchKeywordCollection(?,("high school","school")))
:)

**************************************************************

(: Example 7 :)
(: Dame las calles cercanas a farmacias :)

(:
let $referenceKeywords := rt:getElementsByKeyword(.,"pharmacy")
return
 fn:for-each($referenceKeywords,rt:getLayerByElement(., ?, 0.001))

:)

**************************************************************

(: Example 8 :)
(: Dame las zonas de ocio próximas a hoteles :)

(: declare function local:amenitySite($x){
  count(fn:filter($x, osm:searchTags(?,("bar", "restaurant")))) >= 3
};
 
 osm_gml:_result2Osm(
    fn:filter(
      fn:for-each(rt:getElementsByKeyword(.,”hotel”), rt:getLayerByElement(.,?,0.001))
      ,
      local:amenitySite(?)
    )
)
:)

**************************************************************

(: Example 9 :)
(: Dame una zona cercana a hoteles donde hay más monumentos religiosos :)

(: 
for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"hotel"), 
                   rt:getLayerByElement(.,?,0.001)))
       ,
       osm:addTag(?, "numChurch", 
             count(fn:filter(?, osm:searchOneTag(?,"church"))))
        ) 
 order by $oneLayer/tag/@numChurch
 return 
     osm_gml:_result2Osm($oneLayer[1])  
:)

**************************************************************

(: Example 10 :)
(: This query requests the size of park areas close to the street Paseo de Almeria :)

(: 
declare function local:getArea($oneway as node())
{
 (geo:area(osm_gml:_osm2GmlPolygon($oneway)) * (3.14 div 180) * 6378137) * 10000
};

let $referenceLayer := rt:getLayerByName(.,"Paseo de Almería",0.003),
    $parkAreas := fn:filter($referenceLayer,osm:searchKeyword(?,"park"))          
return
osm_aggr:metricSum($parkAreas,"local:getArea")
:)

**************************************************************

(: Example 11 :)
