import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_library.xq";


let $oneway1 :=
<oneway name="Carretera de Ronda">
    <node id="-1632" visible="true" lat="36.849285" lon="-2.4530232"/>
    <node id="-1634" visible="true" lat="36.8491013" lon="-2.4530405"/>
    <node id="-1636" visible="true" lat="36.8488285" lon="-2.4530322"/>
    <node id="-1638" visible="true" lat="36.8485811" lon="-2.4529746"/>
    <node id="-1640" visible="true" lat="36.8483568" lon="-2.4529097"/>
    <node id="-1642" visible="true" lat="36.8481136" lon="-2.4528206"/>
    <node id="-1644" visible="true" lat="36.847621" lon="-2.4526489"/>
    <node id="-1646" visible="true" lat="36.8475065" lon="-2.452611"/>
    <node id="-1648" visible="true" lat="36.8474205" lon="-2.4525917"/>
    <node id="-1650" visible="true" lat="36.8470783" lon="-2.452574"/>
    <node id="-1652" visible="true" lat="36.8468114" lon="-2.4526091"/>
    <node id="-1654" visible="true" lat="36.8463883" lon="-2.4526911"/>
    <node id="-1656" visible="true" lat="36.8461595" lon="-2.4527171"/>
    <node id="-1658" visible="true" lat="36.8459533" lon="-2.4527047"/>
    <node id="-1660" visible="true" lat="36.8456245" lon="-2.4525807"/>
    <node id="-1662" visible="true" lat="36.8456101" lon="-2.4525671"/>
    <node id="-1664" visible="true" lat="36.8453586" lon="-2.4524722"/>
    <node id="-1666" visible="true" lat="36.8452578" lon="-2.452442"/>
    <node id="-1668" visible="true" lat="36.8451405" lon="-2.4524039"/>
    <node id="-1670" visible="true" lat="36.8448211" lon="-2.4523463"/>
    <node id="-1672" visible="true" lat="36.8445295" lon="-2.4523401"/>
    <node id="-764" visible="true" lat="36.8445295" lon="-2.4523401"/>
    <node id="-762" visible="true" lat="36.8442886" lon="-2.4523673"/>
    <node id="-1460" visible="true" lat="36.844138" lon="-2.4524049"/>
    <node id="-760" visible="true" lat="36.8440093" lon="-2.452427"/>
    <node id="-758" visible="true" lat="36.8437509" lon="-2.4524767"/>
    <node id="-756" visible="true" lat="36.843439" lon="-2.4525623"/>
    <node id="-754" visible="true" lat="36.8430819" lon="-2.4526838"/>
    <node id="-752" visible="true" lat="36.8429366" lon="-2.4527379"/>
    <node id="-750" visible="true" lat="36.8425099" lon="-2.4529168"/>
    <node id="-748" visible="true" lat="36.8422133" lon="-2.4530412"/>
    <node id="-746" visible="true" lat="36.8417431" lon="-2.4532817"/>
    <node id="-1416" visible="true" lat="36.8410435" lon="-2.4536619"/>
    <node id="-744" visible="true" lat="36.84091" lon="-2.4537503"/>
    <node id="-742" visible="true" lat="36.8405641" lon="-2.4539678"/>
    <node id="-740" visible="true" lat="36.8402032" lon="-2.4541732"/>
    <node id="-738" visible="true" lat="36.8397242" lon="-2.4544423"/>
    <node id="-736" visible="true" lat="36.8396764" lon="-2.4544749"/>
    <node id="-734" visible="true" lat="36.8387685" lon="-2.4550117"/>
    <node id="-732" visible="true" lat="36.8382084" lon="-2.45535"/>
    <node id="-730" visible="true" lat="36.8377069" lon="-2.4556232"/>
    <node id="-728" visible="true" lat="36.8374545" lon="-2.4557743"/>
    <node id="-726" visible="true" lat="36.8367762" lon="-2.4561739"/>
    <way id="-1946" visible="true">
      <nd ref="-1632"/>
      <nd ref="-1634"/>
      <nd ref="-1636"/>
      <nd ref="-1638"/>
      <nd ref="-1640"/>
      <nd ref="-1642"/>
      <nd ref="-1644"/>
      <nd ref="-1646"/>
      <nd ref="-1648"/>
      <nd ref="-1650"/>
      <nd ref="-1652"/>
      <nd ref="-1654"/>
      <nd ref="-1656"/>
      <nd ref="-1658"/>
      <nd ref="-1660"/>
      <nd ref="-1662"/>
      <nd ref="-1664"/>
      <nd ref="-1666"/>
      <nd ref="-1668"/>
      <nd ref="-1670"/>
      <nd ref="-1672"/>
      <tag k="highway" v="primary"/>
      <tag k="lanes" v="4"/>
      <tag k="maxspeed" v="50"/>
      <tag k="name" v="Carretera de Ronda"/>
      <tag k="oneway" v="no"/>
    </way>
    <way id="-1914" visible="true">
      <nd ref="-764"/>
      <nd ref="-762"/>
      <nd ref="-1460"/>
      <nd ref="-760"/>
      <nd ref="-758"/>
      <nd ref="-756"/>
      <nd ref="-754"/>
      <nd ref="-752"/>
      <nd ref="-750"/>
      <nd ref="-748"/>
      <nd ref="-746"/>
      <nd ref="-1416"/>
      <nd ref="-744"/>
      <nd ref="-742"/>
      <nd ref="-740"/>
      <nd ref="-738"/>
      <nd ref="-736"/>
      <nd ref="-734"/>
      <nd ref="-732"/>
      <nd ref="-730"/>
      <nd ref="-728"/>
      <nd ref="-726"/>
      <tag k="highway" v="primary"/>
      <tag k="lanes" v="4"/>
      <tag k="maxspeed" v="50"/>
      <tag k="name" v="Carretera de Ronda"/>
      <tag k="oneway" v="no"/>
    </way>
   </oneway>

let $oneway2 :=
  <oneway name="Calle Calzada de Castro">
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
 </oneway>

let $oneway3 := 
<oneway name="Avenida de Nuestra Señora de Montserrat">
    <node id="-1324" visible="true" lat="36.8371669" lon="-2.4529891"/>
    <node id="-1306" visible="true" lat="36.8371582" lon="-2.4532407"/>
    <node id="-48" visible="true" lat="36.8365659" lon="-2.4561704"/>
    <node id="-46" visible="true" lat="36.8365715" lon="-2.456001"/>
    <node id="-44" visible="true" lat="36.8366023" lon="-2.4558209"/>
    <node id="-1320" visible="true" lat="36.8366895" lon="-2.4555074"/>
    <node id="-1186" visible="true" lat="36.8369125" lon="-2.4550318"/>
    <node id="-224" visible="true" lat="36.8370107" lon="-2.4547381"/>
    <node id="-998" visible="true" lat="36.8370703" lon="-2.4545008"/>
    <node id="-1474" visible="true" lat="36.8370984" lon="-2.4542806"/>
    <node id="-1060" visible="true" lat="36.8371152" lon="-2.4539978"/>
    <node id="-1064" visible="true" lat="36.8371347" lon="-2.4535568"/>
    <node id="-1306" visible="true" lat="36.8371582" lon="-2.4532407"/>
    <way id="-1888" visible="true">
      <nd ref="-1324"/>
      <nd ref="-1306"/>
      <tag k="highway" v="residential"/>
      <tag k="lanes" v="2"/>
      <tag k="maxspeed" v="30"/>
      <tag k="name" v="Avenida de Nuestra Señora de Montserrat"/>
      <tag k="oneway" v="no"/>
    </way>
    <way id="-1748" visible="true">
      <nd ref="-48"/>
      <nd ref="-46"/>
      <nd ref="-44"/>
      <nd ref="-1320"/>
      <nd ref="-1186"/>
      <nd ref="-224"/>
      <nd ref="-998"/>
      <nd ref="-1474"/>
      <nd ref="-1060"/>
      <nd ref="-1064"/>
      <nd ref="-1306"/>
      <tag k="highway" v="residential"/>
      <tag k="name" v="Avenida de Nuestra Señora de Montserrat"/>
      <tag k="oneway" v="yes"/>
    </way>
  </oneway>

return 

osm:getDistance($oneway2,$oneway3)