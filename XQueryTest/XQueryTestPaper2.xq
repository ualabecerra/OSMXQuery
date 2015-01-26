import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library_4.xq";

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

(:
let $oneway1 := 
<oneway name="Calle Calzada de Castro">
  <way id="-7423" visible="true">
    <nd ref="-6505"/>
    <nd ref="-5957"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-7417" visible="true">
    <nd ref="-6467"/>
    <nd ref="-5753"/>
    <nd ref="-6313"/>
    <nd ref="-6665"/>
    <nd ref="-7165"/>
    <nd ref="-6885"/>
    <nd ref="-5763"/>
    <nd ref="-6511"/>
    <nd ref="-6437"/>
    <nd ref="-5877"/>
    <nd ref="-7179"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-7337" visible="true">
    <nd ref="-5957"/>
    <nd ref="-5953"/>
    <nd ref="-6467"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <node id="-6505" visible="true" lat="36.8377069" lon="-2.4556232"/>
  <node id="-5957" visible="true" lat="36.8379405" lon="-2.4533034"/>
  <node id="-6467" visible="true" lat="36.8380309" lon="-2.452298"/>
  <node id="-5753" visible="true" lat="36.8380785" lon="-2.4518482"/>
  <node id="-6313" visible="true" lat="36.8381393" lon="-2.4512729"/>
  <node id="-6665" visible="true" lat="36.8381949" lon="-2.4507477"/>
  <node id="-7165" visible="true" lat="36.8382443" lon="-2.4502809"/>
  <node id="-6885" visible="true" lat="36.8382964" lon="-2.4497878"/>
  <node id="-5763" visible="true" lat="36.8383474" lon="-2.4493058"/>
  <node id="-6511" visible="true" lat="36.8383591" lon="-2.4491952"/>
  <node id="-6437" visible="true" lat="36.8383995" lon="-2.4488139"/>
  <node id="-5877" visible="true" lat="36.8384498" lon="-2.4483377"/>
  <node id="-7179" visible="true" lat="36.8385271" lon="-2.4476073"/>
  <node id="-5957" visible="true" lat="36.8379405" lon="-2.4533034"/>
  <node id="-5953" visible="true" lat="36.8379838" lon="-2.4528201"/>
  <node id="-6467" visible="true" lat="36.8380309" lon="-2.452298"/>
</oneway>

let $oneway2 := 
<oneway name="Calle Torres Naharro">
  <way id="-6481" visible="true">
    <nd ref="-5357"/>
    <nd ref="-5355"/>
    <nd ref="-5353"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Torres Naharro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <node id="-5357" visible="true" lat="36.8393301" lon="-2.4489682"/>
  <node id="-5355" visible="true" lat="36.838881" lon="-2.4488933"/>
  <node id="-5353" visible="true" lat="36.8383995" lon="-2.4488139"/>
</oneway>

let $oneway3 := <oneway name="intersectionPoint">
  <node visible="true" lat="36.8383995" lon="-2.4488139"/>
</oneway>

return

osm:getDistanceMbr(1,1,2,2,4,4,7,7)
:)



(: for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"hotel"), rt:getLayerByElement(.,?,0.001)))
    ,
     osm:addTag(?, "numHotels", count(osm:searchOneTag(?,"hotel")))
   ) 
 order by $oneLayer//numHotels
 return osm_gml:_result2Osm($oneLayer[1])
:)
 
(:
 for $oneLayer in 
    fn:for-each(
      (fn:for-each(rt:getElementsByKeyword(.,"amenity"), 
                   rt:getLayerByElement(.,?,0.001)))
       ,
       osm:addTag(?, "numHotels", 
             count(fn:filter(?, osm:searchOneTag(?,"hotel"))))
        ) 
 order by $oneLayer//numHotels
 return 
    $oneLayer 
:)

osm_gml:_result2Osm(
rt:getLayerByName(.,"Calle Calzada de Castro",0))