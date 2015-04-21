import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

import module namespace osm_solap = "osm_solap" at "solapOSMLibrary.xqy"; 

****************************************************************

(: Example 1 :)
(: Dame tamaño total de las zonas ajardinadas próximas al paseo :)
let $parkAreas := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
           osm:searchTags(?,"park"))          
return
osm_solap:metricSum($parkAreas,"osm:getArea")

(: Resultado 482.46411745390435 :)

(: Example 2 :)
(: Dame el número mas frecuente de estrellas de los hoteles cercanos al paseo :)
let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
           osm:searchTags(?,"hotel"))                  
return
osm_solap:metricMode($hotels,"osm:getHotelStars")

(: Example 3 :)
(: Dame el hotel con más estrellas y de mayor tamaño cercano al paseo :)
let $hotels := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
                         osm:searchTags(?,"hotel"))                  
return
osm_solap:metricMax(osm_solap:metricMax($hotels,"osm:getHotelStars"), "osm:getArea")

(: Example 4 :)
(: Dame el restaurante de comida más habitual y más cercano al paseo :)
let $restaurants := fn:filter(rt:getLayerByName(.,"Paseo de Almería",0.003), 
           osm:searchTags(?,"restaurant"))                  
return
osm_solap:metricMin(osm_solap:metricMode($restaurants,
          "osm:getRestaurantCuisine"),"osm:getDistance")