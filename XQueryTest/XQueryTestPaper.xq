import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

(: let $indexName := "C:/Users/Administrator/Desktop/HitoOctubre2014/HitoOctubre2014/rtree_50meters.osm" :)

(: return osm_gml:_result2Osm(fn:filter(rt:getLayerByName($indexName,"Calle Calzada de Castro"), 
osm:searchTags(?,("school", "pharmacy")))) :)

(: return 
osm_gml:_result2Osm(
 osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
 rt:getLayerByName($indexName,"Calle Calzada de Castro"))
) :)

(: return 
osm_gml:_result2Osm(
fn:filter(osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), rt:getLayerByName($indexName,"Calle Calzada de Castro")), osm:isEnding(?, osm:getOneWay($indexName, "Calle Padre Méndez")))
) :)

(: return osm_gml:_result2Osm(
fn:filter(osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), rt:getLayerByName($indexName,"Calle Calzada de Castro")), osm:isNotEnding(?, osm:getOneWay($indexName, "Calle Padre Méndez")))
) :)

(: return 
osm_gml:_result2Osm(
fn:filter(fn:for-each(osm:AllEndingFrom(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
rt:getLayerByName($indexName,"Calle Calzada de Castro")), rt:getLayerByOneWay($indexName,?)) , 
osm:searchTags(?,"school"))
) :)

(: return osm_gml:_result2Osm(fn:filter(rt:getLayerByName($indexName,"Calle Calzada de Castro"), 
osm:searchTags(?,"footway")))  :)

(: return  osm_gml:_result2Osm( 
fn:for-each
(fn:filter(rt:getLayerByName($indexName,"Calle Calzada de Castro"), 
osm:searchTags(?,"school")), osm:addTag(?,"ocio", "colegio"))
 ) :)




(: return osm_gml:_result2Osm(
  osm:unionQuery(osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
 rt:getLayerByName($indexName,"Calle Calzada de Castro")), osm:AllParallels(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
 rt:getLayerByName($indexName,"Calle Calzada de Castro"))
)
) :)




(: fn:count(osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
rt:getLayerByName($indexName,"Calle Calzada de Castro"))) :)
  
   

(: fn:for-each(osm:AllEndingTo(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
rt:getLayerByName(doc($indexName),"Calle Calzada de Castro"))/*, rt:getLayerByOneWay(doc($indexName),?))
:)

(: osm_gml:_result2Osm(
fn:filter(fn:for-each(osm:AllEndingFrom(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
rt:getLayerByName(doc($indexName),"Calle Calzada de Castro"))/*, rt:getLayerByOneWay(doc($indexName),?))/* , 
osm:searchTags(?,"school"))
) :)


(: fn:for-each
(fn:filter(rt:getLayerByName(doc($indexName),"Calle Calzada de Castro")/*, 
osm:searchTags(?,"school")), osm:addTag(?,"ocio", "colegio"))
:)

(:  fn:count(osm:AllCrossing(osm:getOneWay($indexName, "Calle Calzada de Castro"), 
rt:getLayerByName(doc($indexName),"Calle Calzada de Castro"))/*) :)


(: for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"hotel"), rt:getLayerByElement(.,?,0.001)))
    ,
     osm:addTag(?, "numHotels", count(osm:searchOneTag(?,"hotel")))
   ) 
 order by $oneLayer//numHotels
 return osm_gml:_result2Osm($oneLayer[1])
:)

 declare function local:amenitySite($x){
   count(fn:filter($x/*,osm:searchTags(?,("restaurant", "hotel", "theatre", "bar")))) >=3 
   
};

declare function local:createLayer($x){
  <layer>
   {rt:getLayerByElement(collection(), $x ,0.001)}
  </layer>
};
   
  osm_gml:_result2Osm(fn:filter(fn:for-each(rt:getElementsByKeyword(.,"restaurant"), local:createLayer(?)),
            local:amenitySite(?))/*)
  
