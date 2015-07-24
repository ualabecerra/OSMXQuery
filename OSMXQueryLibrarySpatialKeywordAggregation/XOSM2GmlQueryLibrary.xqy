module namespace xosm_gml = "xosm_gml";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';

(: Auxiliary Functions in order to transform OSM geometry into GML geometry :)
(: ************************************************************************ :)

(: Conversor from OSM to GML for Polygons :)

declare function xosm_gml:_osm2GmlPolygon($oneway as node())
{
  if ($oneway/way) then
  <gml:Polygon>
  <gml:LinearRing>
  <gml:coordinates>
  {
   for $node in $oneway/node
   return 
   (concat(concat(data($node/@lat),','),data($node/@lon))) 
  } 
  </gml:coordinates>
  </gml:LinearRing>
  </gml:Polygon> 
  else 
  <gml:Polygon>
  <gml:LinearRing>
  <gml:coordinates>
  {
   concat("0 0", ',', "0 0", ',', "0 0", ',', "0 0")
  } 
  </gml:coordinates>
  </gml:LinearRing>
  </gml:Polygon> 

};

(: Conversor from OSM to GML for Lines :)

declare function xosm_gml:_osm2GmlLine($oneway as node())
{
   if ($oneway//way)
    then 
       <gml:MultiLineString>
      {
      <gml:LineString>
      <gml:coordinates>
      {
       for $node in $oneway/node
       return 
         (concat(concat(data($node/@lat),','),data($node/@lon))) 
      } 
      </gml:coordinates>
      </gml:LineString>
      }
    </gml:MultiLineString> 
    else 
     <gml:Point>
      {
      <gml:coordinates>
      {
       for $node in $oneway/node
       return 
         (concat(concat(data($node/@lat),','),data($node/@lon))) 
      } 
      </gml:coordinates>
      }
    </gml:Point> 
};

(: Conversor from OSM to GML for Points :)

declare function xosm_gml:_osm2GmlPoint($lat as xs:decimal, $lon as xs:decimal)
{
  <gml:Point>
  <gml:coordinates>
  {
  (concat(concat(data($lat),','),data($lon)))
  }
  </gml:coordinates>
  </gml:Point>  
};

declare function xosm_gml:_result2Osm($document as node()*)
{
 <osm version='0.6' upload='true' generator='JOSM'>
 {
  let $document1 := $document
  return 
    if (exists($document1[name(.)='osm']))
    then ($document[name(.) = 'node']) union (($document//way) union ($document//node)) 
    else ($document//way) union ($document//node)
 }
 </osm>
};

