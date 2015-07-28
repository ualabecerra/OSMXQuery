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
let $street := rt:getElementByName(., "Calle Calzada de Castro"), 
    $layer:= rt:getLayerByName(.,"Calle Calzada de Castro", 0.001)
return
fn:filter(fn:filter($layer ,xosm_sp:furtherNorthWays($street ,?)),
xosm_kw:searchKeyword(?,"highway"))
:)

**************************************************************

(: Example 2 :)
(: This query request the streets crossing Calzada de Castro and ending 
   to street Avenida Montserrat :)

(: 
let $s1 := rt:getElementByName(., "Calle Calzada de Castro"),
    $s2 := rt:getElementByName(., "Avenida Nuestra Señora de Montserrat"), 
    $layer := rt:getLayerByName(.,"Calle Calzada de Castro",0), 
    $cross := fn:filter($layer,xosm_sp:isCrossing(?, $s1))
return fn:filter($cross,xosm_sp:isEndingTo(?,$s2))
:)

**************************************************************

(: Example 3 :)
(: This query request the schools close to an street, wherein Calzada de Castro ends. :)

(: 
let $street := rt:getElementByName(., "Calle Calzada de Castro"), 
   $layer := rt:getLayerByName(.,"Calle Calzada de Castro", 0), 
   $ending := fn:filter($layer ,xosm_sp:isEndingTo($street ,?))
return fn:filter(fn:for-each($ending,rt:getLayerByElement(.,?,0.001)),
       xosm_kw:searchKeyword(?,"school"))
:)

**************************************************************

(: Example 4 :)
(: This query requests the buildings in the intersections of Calzada de Castro :)

(: 
let $street := rt:getElementByName(., "Calle Calzada de Castro"),
    $layer := rt:getLayerByName(.,"Calle Calzada de Castro",0),
    $crossing := fn:filter($layer,xosm_sp:isCrossing(?, $street)),
    $intpoints := fn:for-each($crossing,xosm_sp:intersectionPoint(?,$street))
return fn:filter(fn:for-each($intpoints, rt:getLayerByElement(.,?,0.001)),
       xosm_kw:searchKeyword(?,"building"))
:)

**************************************************************

(: Example 5 :)
(: This query requests the schools and high schools close to Calzada de Castro :)

(:
for $layer in rt:getLayerByName(.,"Calle Calzada de Castro",0.001)
where xosm_kw:searchKeywordSet($layer ,("high school","school")) 
return $layer
:)

**************************************************************

(: Example 6 :)
(: This query requests the areas of the city in which there is a pharmacy :)

(:
for $pharmacies in rt:getElementsByKeyword(.,"pharmacy")
return rt:getLayerByElement(.,$pharmacies,0.001)
:)

**************************************************************

(: Example 7 :)
(: This query requests the food areas close to hotels of the city :)

(: for $hotels in rt:getElementsByKeyword(.,"hotel")
   let $layer := rt:getLayerByElement(.,$hotels ,0.002)
   where count(fn:filter($layer,xosm_kw:searchKeywordSet(?,("bar","restaurant")))) >= 3
return $layer
:)

**************************************************************

(: Example 8 :)
(: This query requests the hotel with the greatest number of churches around :)

(: 
let $hotels := rt:getElementsByKeyword(.,"hotel") 
    let $f := function($hotel)
    {-(count(fn:filter(rt:getLayerByElement(collection(),$hotel ,0.001),xosm_kw:searchKeyword(?,"church"))))}
return fn:sort($hotels ,$f)[1]
:)

**************************************************************

(: Example 9 :)
(: This query requests the size of park areas close to the street Paseo de Almeria :)

(: 
let $layer := rt:getLayerByName(.,"Paseo de Almería",0.003), 
    $parkAreas := fn:filter($layer,xosm_kw:searchKeyword(?,"park"))
return
xosm_ag:metricSum($parkAreas ,"area")
:)

**************************************************************

(: Example 10 :)
(: This query requests the most frequent star rating of hotels close to Paseo de Almeria :)

(: 
let $layer := rt:getLayerByName(.,"Paseo de Almería",0.003), 
     $hotels := fn:filter($layer,xosm_kw:searchKeyword(?,"hotel"))
return
xosm_ag:metricMode($hotels ,"stars")
:)

**************************************************************
    
(: Example 11 :)
(: This query requests the biggest hotels of top star ratings close to Paseo de Almeria :)

(: 
let $layer := rt:getLayerByName(.,"Paseo de Almería",0.003),
    $hotels := fn:filter($layer,xosm_kw:searchKeyword(?,"hotel"))
return
 xosm_ag:metricMax(xosm_ag:metricMax($hotels ,"stars"), "area")
:)

**************************************************************

(: Example 12 :)
(: This query requests the closest restaurant to Paseo de Almeria having the most typical cuisine :)

(: 
let $layer := rt:getLayerByName(.,"Paseo de Almeria",0.003),
$restaurants := fn:filter($layer,xosm_kw:searchKeyword(?,"restaurant"))
return
xosm_ag:metricMin(xosm_ag:metricMode($restaurants ,"cuisine"),"distance")
:)