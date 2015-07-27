import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

import module namespace osm_aggr = "osm_aggr" at "OSMAggregationLibrary.xqy";

**************************************************************

(: Example 1 :)
(: This query requests the streets to the north of the street Calzada de Castro :)

(: 
let $referenceWay := rt:getElementByName(., "Calle Calzada de Castro"),
    $referenceLayer:= rt:getLayerByName(.,"Calle Calzada de Castro", 0.001)
return 
 fn:filter(fn:filter($referenceLayer, xosm_sp:furtherNorthWays($referenceWay,?)), 
           xosm_kw:searchKeyword(?,"highway"))
:)

**************************************************************

(: Example 2 :)
(: This query request the streets crossing Calzada de Castro and ending 
   to street Avenida Montserrat :)

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
(: This query request the schools close to an street, wherein Calzada de Castro ends. :)

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
(: This query requests the streets close to Calzada de Castro, 
   in which there is a supermarket El Arbol” and a pharmacy :)

(: 
xosm_sp:intersectionQuery( 
   xosm_sp:unionQuery(rt:getLayerByName(.,"El Arbol", 0.001), 
                      rt:getLayerByName(.,"pharmacy", 0.001)),
   rt:getLayerByName(.,"Calle Calzada de Castro", 0.001))
:)

**************************************************************

(: Example 5 :)
(: This query requests the buildings in the intersections of Calzada de Castro :)

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
(: This query requests the schools and high schools close to Calzada de Castro :)

(:
let $referenceLayer := rt:getLayerByName(.,"Calle Calzada de Castro",0.001)
return 
 fn:filter($referenceLayer,
           xosm_kw:searchKeywordSet(?,("high school","school")))
:)

**************************************************************

(: Example 7 :)
(: This query requests the areas of the city in which there is a pharmacy :)

(:
let $referenceOneways := rt:getElementsByKeyword(.,"pharmacy")
return
 fn:for-each($referenceOneways,rt:getLayerByElement(., ?, 0.001))
:)

**************************************************************

(: Example 8 :)
(: This query requests the food areas close to hotels of the city :)

(: let $layerHotels := rt:getElementsByKeyword(.,"hotel")
return
 fn:filter(fn:for-each($layerHotels,
  function($hotel)
  {<hotelLayer>
     {rt:getLayerByElement(collection(),$hotel,0.002)}
  </hotelLayer>}),
     function($hotelLayer)
     {count(fn:filter($hotelLayer/*, 
     xosm_kw:searchKeywordSet(?,("bar","restaurant","cafe")))) >= 3})
:)

**************************************************************

(: Example 9 :)
(: This query requests the hotel with the greatest number of churches around :)

(: 
let $layerHotels := rt:getElementsByKeyword(.,"hotel")
return
fn:sort($layerHotels,
      function($hotel) 
      {-(count(fn:filter(rt:getLayerByElement(collection(),$hotel ,0.001),
      xosm_kw:searchKeyword(?,("church")))))})[1]
:)

**************************************************************

(: Example 10 :)
(: This query requests the size of park areas close to the street Paseo de Almeria :)

(: 
let $referenceLayer := rt:getLayerByName(.,"Paseo de Almería",0.003),
    $parkAreas := fn:filter($referenceLayer,xosm_kw:searchKeyword(?,"park"))          
return
xosm_ag:metricSum($parkAreas,"area")
:)

**************************************************************

(: Example 11 :)
(: This query requests the most frequent star rating of hotels close to Paseo de Almeria :)

(: 
let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
               xosm_kw:searchKeyword(?,"hotel"))                  
return
    xosm_ag:metricMode($hotels,"stars")
:)

**************************************************************
    
(: Example 12 :)
(: This query requests the biggest hotels of top star ratings close to Paseo de Almeria :)

(: 
let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
                         xosm_kw:searchKeyword(?,"hotel"))                  
return
   xosm_ag:metricMax(xosm_ag:metricMax($hotels,"stars"), "area"
:)

**************************************************************

(: Example 13 :)
(: This query requests the closest restaurant to Paseo de Almeria having the most typical cuisine :)

(: 
let $restaurants := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
                    xosm_kw:searchKeyword(?,"restaurant"))                  
return
   xosm_ag:metricMin(xosm_ag:metricMode($restaurants,"cuisine"),"distance")
:)