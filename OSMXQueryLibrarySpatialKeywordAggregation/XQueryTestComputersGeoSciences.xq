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
 fn:filter(fn:filter($referenceLayer, xosm_sp:furtherNorthWays($referenceWay,?)), 
           xosm_kw:searchKeyword(?,"highway"))
:)

**************************************************************

(: Example 2 :)
(: Dame todas las calles que cruzan Calzada de Castro y terminan en 
   Avenida Nuestra Señora de Monsterrat :)

(: 
let $referenceWay1 := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceWay2 := rt:getElementByName(., "Avenida Nuestra Señora de Montserrat"),
    $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0),
    $onewaysCrossing := fn:filter($referenceLayer, 
                        xosm_sp:isCrossing(?, $referenceWay1))
return
    fn:filter($onewaysCrossing,xosm_sp:isEndingTo(?,$referenceWay2)) 
:)

**************************************************************

(: Example 3 :)
(: Dame todos los colegios proximos a una calle que finaliza en Calzada de Castro :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro", 0),
    $onewaysAllEndingTo := fn:filter($referenceLayer, 
                           xosm_sp:isEndingTo($referenceWay,?))
return
  fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByElement(.,?,0.001)), 
            xosm_kw:searchKeyword(?,"school"))
:)

**************************************************************

(: Example 4 :)
(: Dame todas las calles en las que hay una farmacia o un Supermercado El Arbol
   proximas a Calzada de Castro :)

(: 
xosm_sp:intersectionQuery( 
   xosm_sp:unionQuery(rt:getLayerByName(.,"El Arbol", 0.001), 
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
                        xosm_sp:isCrossing(?, $referenceWay)),
    $intersectionPoints := fn:for-each($onewaysCrossing, 
                           xosm_sp:intersectionPoint(?,$referenceWay))
return 
fn:filter(
   fn:for-each($intersectionPoints, rt:getLayerByElement(.,?,0.001)),
               xosm_kw:searchKeyword(?,"building"))
:)

**************************************************************

(: Example 6 :)
(: Dame todos los colegios e institutos cerca de Calzada de Castro :)

(:
let $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0.001)
return 
 fn:filter($referenceLayer,
           xosm_kw:searchKeywordSet(?,("high school","school")))
:)

**************************************************************

(: Example 7 :)
(: Dame las calles cercanas a farmacias :)

(:
let $referenceOneways := rt:getElementsByKeyword(.,"pharmacy")
return
 fn:for-each($referenceOneways,rt:getLayerByElement(., ?, 0.001))
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

(: let $referenceLayer := rt:getLayerByName(.,"Paseo de Almería",0.003),
    $parkAreas := fn:filter($referenceLayer,xosm_kw:searchKeyword(?,"park"))          
return
xosm_ag:metricSum($parkAreas,"area")
:)

**************************************************************

(: Example 11 :)

let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
               xosm_kw:searchKeyword(?,"hotel"))                  
return
    xosm_ag:metricMode($hotels,"stars")
    
(: Example 12 :)

let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
                         xosm_kw:searchKeyword(?,"hotel"))                  
return
   xosm_ag:metricMax(xosm_ag:metricMax($hotels,"stars"), "area"
   
(: Example 13 :)

let $restaurants := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
                    xosm_kw:searchKeyword(?,"restaurant"))                  
return
   xosm_ag:metricMin(xosm_ag:metricMode($restaurants,"cuisine"),"distance")    