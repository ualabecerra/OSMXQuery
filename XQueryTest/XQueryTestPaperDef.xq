import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

(: Dame todos los colegios próximos a Calzada de Castro :)

osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,"school")))

(: Dame todos los colegios y farmacias próximas a Calzada de Castro :)

osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,("school", "pharmacy"))))

(: Dame todas las calles próximas a Calzada de Castro que la cruzan :)

osm_gml:_result2Osm(
 osm:AllCrossing(osm:getOneWay(., "Calle Calzada de Castro"), 
 rt:getLayerByName(.,"Calle Calzada de Castro"))
)
------------------------- Versión High - Order
osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
  osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro")))
)

(: Dame todas las calles próximas a Calzada de Castro que la cruzan y acaban en Padre Méndez :)

osm_gml:_result2Osm(
fn:filter(osm:AllCrossing(osm:getOneWay(., "Calle Calzada de Castro"), rt:getLayerByName(.,"Calle Calzada de Castro")), osm:isEnding(?, osm:getOneWay(., "Calle Padre Méndez")))
)

------------------------- Versión High - Order

let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro")))
return 
osm_gml:_result2Osm(
fn:filter($onewaysCrossing, osm:isEnding(?, osm:getOneWay(., "Calle Padre Méndez")))
)

(: Dame todas las calles próximas a Calzada de Castro que la cruzan y no acaban en Padre Méndez :)

osm_gml:_result2Osm(
fn:filter(osm:AllCrossing(osm:getOneWay(., "Calle Calzada de Castro"), rt:getLayerByName(.,"Calle Calzada de Castro")), osm:isNotEndingTo(?, osm:getOneWay(., "Calle Padre Méndez")))
)

------------------------- Versión High - Order

let $onewaysCrossing :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro")))
return 
osm_gml:_result2Osm(
fn:filter($onewaysCrossing, osm:isNotEndingTo(?, osm:getOneWay(., "Calle Padre Méndez")))
)

(: Dame todas los colegios que están próximos a una calle que acaba en Calzada de Castro :)

(: La consulta  está fantástica. El problema es que necesitamos un getLayer que dada una oneway, obtenga la
capa de proximidad. En definitiva que no se puede componer con getLayer. Por eso he creado getLayerByOneWay. Por cierto está preciosa porque maneja filter y for-each :)

osm_gml:_result2Osm(
fn:filter(fn:for-each(osm:AllEndingTo(osm:getOneWay(., "Calle Calzada de Castro"), 
rt:getLayerByName(.,"Calle Calzada de Castro")), rt:getLayerByOneWay(.,?)) , 
osm:searchTags(?,"school"))
)

------------------------- Versión High - Order

let $onewaysAllEndingTo :=  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isEndingTo(?, osm:getOneWay(., "Calle Calzada de Castro")))

return 
osm_gml:_result2Osm(
fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByOneWay(.,?)) , osm:searchTags(?,"school"))
)

(: Dame todas las calles peatonales próximas a Calzada de Castro :)

osm_gml:_result2Osm(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,"footway")))

(: Incorpora en todos los colegios próximos a Calzada de Castro la etiqueta colegio por cuestiones
de idioma :)

osm_gml:_result2Osm( 
fn:for-each
(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,"school")), osm:addTag(?,"ocio", "colegio"))
 ) 

(: Dame el numero de calles próximas a Calzada de Castro que la cruzan :)

fn:count(osm:AllCrossing(osm:getOneWay(., "Calle Calzada de Castro"), 
rt:getLayerByName($indexName,"Calle Calzada de Castro")))

------------------------- Versión High - Order

fn:count(fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro"))))

(: Usando la unión dame las calles que cruzan o acaban en Calzada de Castro :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
 osm:unionQuery(
   fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro"))), 
   fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isEndingTo(?, osm:getOneWay(., "Calle Calzada de Castro"))) 
) 
)

(: Usando la intersección dame las calles que cruzan Calzada de Castro y acaban en Padre Méndez :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
 osm:intersectionQuery(
   fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isCrossing(?, osm:getOneWay(., "Calle Calzada de Castro"))), 
   fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isEndingTo(?, osm:getOneWay(., "Calle Padre Méndez")))) 
)

(: Dame las calles en las que haya un supermercado Maxi Dia próximas a Calzada de Castro :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
  osm:intersectionQuery(rt:getLayerByName(.,"Maxi Dia"), rt:getLayerByName(.,"Calle Calzada de Castro"))
)

(: Dame las calles en las que haya una farmacia y un supermercado Maxi Dia próximas a Calzada de Castro :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
   osm:intersectionQuery( 
   osm:unionQuery(rt:getLayerByName(.,"Maxi Dia"), rt:getLayerByName(.,"pharmacy")),
  rt:getLayerByName(.,"Calle Calzada de Castro")
) 
)

(: Dame las calles en las que haya alguna farmacia próximas a Calzada de Castro :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
  osm:intersectionQuery(rt:getLayerByName(.,"pharmacy"), rt:getLayerByName(.,"Calle Calzada de Castro"))
) 

(: Dame las calles que conecta Calzada de Castro :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isContinuationOf(?, osm:getOneWay(., "Calle Calzada de Castro")))
  
 (: Dame las calles próximas a Calzada de Castro que son paralelas a ella :)
------------------------- Versión High - Order

osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:isParallel(?, osm:getOneWay(., "Calle Calzada de Castro")))
)

 (: Dame las calles próximas a Calzada de Castro pero más al norte :)
------------------------- Versión High - Order
osm_gml:_result2Osm(
  fn:filter(rt:getLayerByName(.,"Calle Calzada de Castro"), osm:furtherNorthWays(osm:getOneWay(., "Calle Calzada de Castro"),?))
) 