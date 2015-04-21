declare namespace functx = "http://www.functx.com";
<osm  version='0.6' upload='true' generator='JOSM'>
{for $mbr in //node[@x] union //mbr union //leaf
let $id := abs(random:integer())
return
(:
$mbr/way
union
$mbr/node[not(@x)]
union
:)
<node id="{concat($id,"1")}" lat="{$mbr/@y}" lon="{$mbr/@x}" visible="true" version="6" />
union
<node id="{concat($id,"2")}" lat="{$mbr/@y}" lon="{$mbr/@z}"   visible="true" version="6" />
union
<node id="{concat($id,"3")}" lat="{$mbr/@t}" lon="{$mbr/@z}"   visible="true" version="6" />
union
<node id="{concat($id,"4")}" lat="{$mbr/@t}" lon="{$mbr/@x}" visible="true" version="6" />
union 
<way id="{$id}"    visible="true" version="6">
<tag k='name' v='mbr' />
<tag k='building' v='yes' />
<nd ref="{concat($id,"1")}"/>
<nd ref="{concat($id,"2")}"/>
<nd ref="{concat($id,"3")}"/>
<nd ref="{concat($id,"4")}"/>
<nd ref="{concat($id,"1")}"/>
</way>
}
</osm>