import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";


declare function local:distanceTag($x,$oneway){
  osm:addTag($x, "distance", osm:getDistance($x, $oneway))
};

let $calzadaCastro := <oneway name="Calle Calzada de Castro">
  <way id="-1877" visible="true">
    <nd ref="-959"/>
    <nd ref="-411"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-1871" visible="true">
    <nd ref="-921"/>
    <nd ref="-207"/>
    <nd ref="-767"/>
    <nd ref="-1119"/>
    <nd ref="-1619"/>
    <nd ref="-1339"/>
    <nd ref="-217"/>
    <nd ref="-965"/>
    <nd ref="-891"/>
    <nd ref="-331"/>
    <nd ref="-1633"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-1791" visible="true">
    <nd ref="-411"/>
    <nd ref="-407"/>
    <nd ref="-921"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <node id="-959" visible="true" lat="36.8377069" lon="-2.4556232"/>
  <node id="-411" visible="true" lat="36.8379405" lon="-2.4533034"/>
  <node id="-921" visible="true" lat="36.8380309" lon="-2.452298"/>
  <node id="-207" visible="true" lat="36.8380785" lon="-2.4518482"/>
  <node id="-767" visible="true" lat="36.8381393" lon="-2.4512729"/>
  <node id="-1119" visible="true" lat="36.8381949" lon="-2.4507477"/>
  <node id="-1619" visible="true" lat="36.8382443" lon="-2.4502809"/>
  <node id="-1339" visible="true" lat="36.8382964" lon="-2.4497878"/>
  <node id="-217" visible="true" lat="36.8383474" lon="-2.4493058"/>
  <node id="-965" visible="true" lat="36.8383591" lon="-2.4491952"/>
  <node id="-891" visible="true" lat="36.8383995" lon="-2.4488139"/>
  <node id="-331" visible="true" lat="36.8384498" lon="-2.4483377"/>
  <node id="-1633" visible="true" lat="36.8385271" lon="-2.4476073"/>
  <node id="-411" visible="true" lat="36.8379405" lon="-2.4533034"/>
  <node id="-407" visible="true" lat="36.8379838" lon="-2.4528201"/>
  <node id="-921" visible="true" lat="36.8380309" lon="-2.452298"/>
</oneway>


return 

for $oneway in 
      fn:for-each(fn:filter(
             rt:getLayerByName(.,"Calle Calzada de Castro", 0.01), 
             osm:furtherNorthWays(rt:getElementByName(., "Calle Calzada de Castro"),?))
      ,
      local:distanceTag(?,$calzadaCastro)
 )
 order by $oneway/tag/@distance
 return osm_gml:_result2Osm($oneway[1])
