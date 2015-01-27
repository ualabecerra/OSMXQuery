import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";

let $oneway1 := <oneway name="Calle Calzada de Castro">
  <way id="-1838" visible="true">
    <nd ref="-1278"/>
    <nd ref="-1282"/>
    <nd ref="-768"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-1758" visible="true">
    <nd ref="-768"/>
    <nd ref="-1482"/>
    <nd ref="-922"/>
    <nd ref="-570"/>
    <nd ref="-70"/>
    <nd ref="-350"/>
    <nd ref="-1472"/>
    <nd ref="-724"/>
    <nd ref="-798"/>
    <nd ref="-1358"/>
    <nd ref="-56"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <way id="-1752" visible="true">
    <nd ref="-730"/>
    <nd ref="-1278"/>
    <tag k="highway" v="residential"/>
    <tag k="name" v="Calle Calzada de Castro"/>
    <tag k="oneway" v="yes"/>
  </way>
  <node id="-1278" visible="true" lat="36.8379405" lon="-2.4533034"/>
  <node id="-1282" visible="true" lat="36.8379838" lon="-2.4528201"/>
  <node id="-768" visible="true" lat="36.8380309" lon="-2.452298"/>
  <node id="-768" visible="true" lat="36.8380309" lon="-2.452298"/>
  <node id="-1482" visible="true" lat="36.8380785" lon="-2.4518482"/>
  <node id="-922" visible="true" lat="36.8381393" lon="-2.4512729"/>
  <node id="-570" visible="true" lat="36.8381949" lon="-2.4507477"/>
  <node id="-70" visible="true" lat="36.8382443" lon="-2.4502809"/>
  <node id="-350" visible="true" lat="36.8382964" lon="-2.4497878"/>
  <node id="-1472" visible="true" lat="36.8383474" lon="-2.4493058"/>
  <node id="-724" visible="true" lat="36.8383591" lon="-2.4491952"/>
  <node id="-798" visible="true" lat="36.8383995" lon="-2.4488139"/>
  <node id="-1358" visible="true" lat="36.8384498" lon="-2.4483377"/>
  <node id="-56" visible="true" lat="36.8385271" lon="-2.4476073"/>
  <node id="-730" visible="true" lat="36.8377069" lon="-2.4556232"/>
  <node id="-1278" visible="true" lat="36.8379405" lon="-2.4533034"/>
</oneway>

let $oneway2 :=  <oneway name="ACUYO IRIARTE">
  <node id="-1110" visible="true" lat="36.8379046" lon="-2.4528582">
    <tag k="addr:housename" v="Calzada de Castro"/>
    <tag k="addr:housenumber" v="30"/>
    <tag k="addr:postcode" v="04006"/>
    <tag k="amenity" v="pharmacy"/>
    <tag k="name" v="ACUYO IRIARTE"/>
  </node>
</oneway>

let $oneway3 := <oneway name="Colegio Ciudad de Almeria">
  <way id="-1760" action="modify" visible="true">
    <nd ref="-1148"/>
    <nd ref="-1082"/>
    <nd ref="-1042"/>
    <nd ref="-994"/>
    <nd ref="-1148"/>
    <tag k="amenity" v="school"/>
    <tag k="building" v="yes"/>
    <tag k="name" v="Colegio Ciudad de Almeria"/>
  </way>
  <node id="-1148" visible="true" lat="36.838943" lon="-2.4518178"/>
  <node id="-1082" visible="true" lat="36.8391169" lon="-2.4514318"/>
  <node id="-1042" visible="true" lat="36.8395599" lon="-2.4514625"/>
  <node id="-994" visible="true" lat="36.8395616" lon="-2.4518987"/>
  <node id="-1148" visible="true" lat="36.838943" lon="-2.4518178"/>
</oneway>

return 

 rt:getLayerByName(.,"Calle Calzada de Castro", 0.001) 
