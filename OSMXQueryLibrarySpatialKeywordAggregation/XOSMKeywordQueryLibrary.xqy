module namespace xosm_kw = "xosm_kw";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';


(:                           Keyword Operators                              :)
(: ************************************************************************ :)

declare function xosm_kw:searchKeywordCollection($oneway as node(), $keywordCollection as xs:string*)
{
  if (some $value in 
  (distinct-values(
  for $keyword in $keywordCollection
    return xosm_kw:searchKeyword($oneway,$keyword))) satisfies ($value = true()))
    then true()
    else false()
};

declare function xosm_kw:searchKeyword($oneway as node(), $keyword as xs:string)
{
  let $item := $oneway//*[name(.)="tag"]
  return
    if ((some $att in $item/@v satisfies ($att = $keyword)) 
    or (some $att in $item/@k  satisfies ($att = $keyword)))
   then true()
   else false()
};

declare function xosm_kw:searchTag($oneway as node(), $kValue as xs:string, $vValue)
{
  $oneway/tag[@k = $kValue]/@v = $vValue
};

declare function xosm_kw:getTagValue($oneway as node(), $kValue as xs:string)
{
(: Hacer un switch para controlar todos los casos :)  
  
 (:xs:double($oneway/tag[@k=$kValue]/@v) :)
 if ($oneway//tag[@k=$kValue]) then
  $oneway//tag[@k=$kValue]/@v
 else 
  xs:string(-1)
};
