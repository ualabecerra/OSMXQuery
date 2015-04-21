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
<node id="{concat($id,"1")}" lat="{$mbr/@x}" lon="{$mbr/@y}" visible="true" version="6" />
union
<node id="{concat($id,"2")}" lat="{$mbr/@z}" lon="{$mbr/@y}"   visible="true" version="6" />
union
<node id="{concat($id,"3")}" lat="{$mbr/@z}" lon="{$mbr/@t}"   visible="true" version="6" />
union
<node id="{concat($id,"4")}" lat="{$mbr/@x}" lon="{$mbr/@t}" visible="true" version="6" />
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