module namespace osm = "osm";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

import module namespace rt = "rtree" at "rtree_library.xq";

declare namespace gml='http://www.opengis.net/gml';

(:                           Query Pattterns                                :)
(: ************************************************************************ :)


declare function osm:booleanQuery($oneway1 as node(), $oneway2 as node(), $functionName as xs:string)
{
  let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
      $multiLineString2 := osm_gml:_osm2GmlLine($oneway2)
  let $spatialFunction := fn:function-lookup(xs:QName($functionName),2)
  return
    $spatialFunction($mutliLineString1,$multiLineString2)
};

declare function osm:unionQueryPattern($oneway as node(), $document as node()*, $operatorCollection as xs:string*)
{
   for $operatorValue in $operatorCollection
      let $spatialFunction := fn:function-lookup(xs:QName($operatorValue),2)
      return $spatialFunction($oneway,$document)
};

declare function osm:unionQuery($onewayResult1 as node()*, $onewayResult2 as node()*)
{
  $onewayResult1 union $onewayResult2
};

declare function osm:intersectionQuery($onewayResult1 as node()*, $onewayResult2 as node()*)
{
  for $oneway in $onewayResult1
    let $name := data($oneway/@name)
    return
     for $oneway2 in $onewayResult2
        return
            if (data($oneway2/@name) = $name)
            then $oneway2
            else () 
};

declare function osm:exceptQuery($onewayResult1 as node()*, $onewayResult2 as node()*)
{
 $onewayResult1 except $onewayResult2
};


(:                           Keyword Operators                                :)
(: ************************************************************************ :)


declare function osm:addTag($node as node(), $kValueToAdd as xs:string, $vValueToAdd as xs:string)
{
  <oneway>
  {
   ( for $item in $node/*[name(.)='way']
    let $idValue := $item/@id
    return 
  <way id = "{$idValue}" visible = 'true' version = '6'>
   { 
    (for $tag in $item/*
    return ($tag))
    union (<tag k='{$kValueToAdd}' v='{$vValueToAdd}' />)
   }   
   </way>
 ) union
 (for $nodeid in $node/*[name(.)='node']
  return $nodeid) 
}
</oneway>
};

declare function osm:removeTag($node as node(), $kValueToRemove as xs:string, $vValueToRemove as xs:string)
{
 let $idValue := $node/@id
 return
 <way id = "{$idValue}" visible = 'true'>
 {
    (for $item in $node/*
    let $tagValuek := $item/@k, $tagValuev := $item/@v 
    return 
      if ((data($tagValuek) = $kValueToRemove) and (data($tagValuev) = $vValueToRemove))
      then ()
      else $item)
 };
</way> 
};

declare function osm:replaceTag($node as node(), $kValue as xs:string, $vValueToReplace as xs:string)
{
 let $idValue := $node/@id
 return
 <way id = "{$idValue}" visible = 'true'>
 {
    (for $item in $node/*
    let $tagValuek := $item/@k 
    return 
      if ((data($tagValuek) = $kValue))
      then ()
      else $item)
     union (<tag k='{$kValue}' v='{$vValueToReplace}' />)
 };
</way> 
};

declare function osm:searchOneTag($node as node(), $valueToSearch as xs:string)
{
  let $item := $node//*[name(.)="tag"]
  return
    if ((some $att in $item/@v satisfies ($att = $valueToSearch)) or (some $att in $item/@k 
    satisfies ($att = $valueToSearch)))
   then true()
   else false()
};

declare function osm:searchTags($node as node(), $collectionValueToSearch as xs:string*)
{
  let $item := $node
  return
  if (some $value in 
  (distinct-values(
  for $valueToSearch in $collectionValueToSearch
    return osm:searchOneTag($node,$valueToSearch))) satisfies ($value = true()))
    then true()
    else false()
};

(:                           Urban Operators                                :)
(: ************************************************************************ :)

(: Returns true whenever a point (i.e. $lat and $lon) is in a way :)

declare function osm:inWay($oneway-point as node(), $oneway as node())
{
  let $lat := $oneway-point/node/@lat, $lon := $oneway-point/node/@lon
  let $point := osm_gml:_osm2GmlPoint($lat,$lon), $line := osm_gml:_osm2GmlLine($oneway)
  return geo:contains($line,$point)
};

(: Returns the ways in which a point (i.e. $lat and $lon) is :)

declare function osm:WaysOfaPoint($node as node(), $document as node()*)
{
  let $lat := $node/@lat, $lon := $node/@lon
  let $point := osm_gml:_osm2GmlPoint($lat,$lon) 
  for $oneway in $document//oneway
  return
     let $line := osm_gml:_osm2GmlLine($oneway)
     return 
      if (geo:contains($line, $point)) then $oneway
      (: osm_file:_gml2Osm($oneway,$document) :)
       else () 
};

(: Returns true whenever node1 and node2 are in the same street :)

declare function osm:inSameWay($node1 as node(), $node2 as node(), $document as node()*)
{
  let $lat1 := $node1/@lat, $lon1 := $node1/@lon
  let $lat2 := $node2/@lat, $lon2 := $node2/@lon
  let
      $oneway1 := osm:WaysOfaPoint($node1,$document), 
      $oneway2 := osm:WaysOfaPoint($node2,$document)
  return     
   some $x in $oneway1 satisfies (some $y in $oneway2 satisfies
    (let $line1 := osm_gml:_osm2GmlLine($x), 
        $line2 := osm_gml:_osm2GmlLine($y)
    return geo:equals($line1,$line2))) 
};          
 
(: Returns the shortest distance between two ways, 
   where that distance is the distance between a point on each of the geometries :)
   
declare function osm:getDistanceBetweenGeometries($oneway1 as node(), $oneway2 as node())
{
  let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
      $multiLineString2 := osm_gml:_osm2GmlLine($oneway2)
  return
    geo:distance($mutliLineString1,$multiLineString2)  
};
 
(: Returns true whenever a way crosses another one :)

declare function osm:isCrossing($oneway1 as node(), $oneway2 as node())
{
  osm:booleanQuery($oneway1,$oneway2,"geo:crosses")
};

(: Returns true whenever a ways is parallel to another one :)

declare function osm:isParallel($oneway1 as node(), $oneway2 as node())
{
  osm:booleanQuery($oneway1,$oneway2,"geo:disjoint")
};

(: Returns true whenever a ways ends to another one :)

declare function osm:isEnding($oneway1 as node(), $oneway2 as node())
{
 if (osm:booleanQuery($oneway1,$oneway2,"geo:touches"))
 then
    let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
        $multiLineString2 := osm_gml:_osm2GmlLine($oneway2),
        $intersection_point := geo:intersection($mutliLineString1,$multiLineString2), 
        $start_point := geo:start-point($mutliLineString1/*),
        $end_point := geo:end-point($mutliLineString1/*)
    return (geo:equals($intersection_point/*,$start_point/*) or 
            geo:equals($intersection_point/*,$end_point/*))
    else false()  
};

declare function osm:isEndingFrom($oneway1 as node(), $oneway2 as node())
{
 osm:isEnding($oneway2,$oneway1)
};

declare function osm:isNotEndingFrom($oneway1 as node(), $oneway2 as node())
{
 not(osm:isEndingFrom($oneway1,$oneway2))
};

declare function osm:isEndingTo($oneway1 as node(), $oneway2 as node())
{
 osm:isEnding($oneway1,$oneway2)
};

declare function osm:isNotEndingTo($oneway1 as node(), $oneway2 as node())
{
 not(osm:isEndingTo($oneway1,$oneway2))
};

declare function osm:isContinuationOf($oneway1 as node(), $oneway2 as node())
{
 if (osm:booleanQuery($oneway1,$oneway2,"geo:touches"))
 then
    let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
        $multiLineString2 := osm_gml:_osm2GmlLine($oneway2),
        $start_point := geo:start-point($mutliLineString1/*),
        $end_point := geo:end-point($multiLineString2/*)
    return (geo:equals($start_point/*,$end_point/*))
    else false()  
};

declare function osm:isNotContinuationOf($oneway1 as node(), $oneway2 as node())
{
  not(osm:isContinuationOf($oneway1,$oneway2))
};

(: Function in order to determinate if second node is northernmost than first one. Using latitudes by considering points in noth and south hemispheres :)
           
declare function osm:furtherNorthPoints($node1 as node(), $node2 as node())
{
  let $lat1 := $node1/@lat, $lat2 := $node2/@lat
  return
  (: Case 1:  both nodes in positive Ecuador hemisphere :)
    if ($lat1 > 0 and $lat2 > 0) then 
        if (($lat2 - $lat1) > 0) then true()
                                 else false() 
    else 
  (: Case 2: both nodes in negative Ecuador hemisphere :)  
      if ($lat1 < 0  and $lat2 < 0) then      
      if (((-$lat2) - (-$lat1)) < 0) then true()
                                      else false()
      else
  (: Case 3: First node in positive Ecuador hemisphere, Second node in negative Ecuador hemisphere:)
     if ($lat1 > 0 and $lat2 < 0) then false()
  (: Case 4: First node in negative Ecuador hemisphere, Second node in positive Ecuador hemisphere :)
                                 else true()
};                              

(: Function in order to determinate if second node is further south than first one. furtherNorth negation :)

declare function osm:furtherSouthPoints($node1 as node(), $node2 as node())
{
  not(osm:furtherNorthPoints($node1,$node2))
};

(: Function in order to determinate if second node is further east than first node. Using latitudes by considering nodes in west and east hemispheres :)
           
declare function osm:furtherEastPoints($node1 as node(), $node2 as node())
{
  let $lon1 := $node1/@lon, $lon2 := $node2/@lon
  return 
  (: Case 1:  both nodes in positive Greenwich meridian :)
    if ($lon1 > 0 and $lon2 > 0) then 
        if (($lon2 - $lon1) > 0) then true()
                                 else false() 
    else 
  (: Case 2: both nodes in negative Greenwich meridian :)  
      if ($lon1 < 0  and $lon2 < 0) then      
      if (((-$lon2) - (-$lon1)) < 0) then true()
                                      else false()
      else
  (: Case 3: First node in positive Greenwich meridian, Second node in negative Greenwich meridian :)
     if ($lon1 > 0 and $lon2 < 0) then false()
  (: Case 4: First node in negative Greenwich meridian, Second node in positive Greenwich meridian :)
                                  else true()
};                              

(: Function in order to determinate if second node is further weast than first node. furtherEast negation :)

declare function osm:furtherWestPoints($node1 as node(), $node2 as node())
{
  not(osm:furtherEastPoints($node1,$node2))
};

declare function osm:furtherNorthWays($oneway1 as node(), $oneway2 as node())
{
  let $multiLineString1 := osm_gml:_osm2GmlLine($oneway1)
  let $multilineString2 := osm_gml:_osm2GmlLine($oneway2)
  let $start_point1 := geo:start-point($multiLineString1/*),
      $end_point1 := geo:end-point($multiLineString1/*)
  return 
    if (geo:dimension($multilineString2) = 1)
    then let $start_point2 := geo:start-point($multilineString2/*),
         $end_point2 := geo:end-point($multilineString2/*)
    return 
      (osm:furtherNorthPoints( 
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>
       ,<node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
       lon = "{fn:substring-after($end_point2,',')}"/>
        ) 
      )      
 (:      (osm:furtherNorthPoints( 
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>, 
        <node visible = 'true' lat = "{fn:substring-before($start_point2,',')}" 
       lon = "{fn:substring-after($start_point2,',')}"/>) )
:)
(:        and (osm:furtherNorthPoints( 
       <node visible = 'true' lat = "{fn:substring-before($end_point1,',')}" 
       lon = "{fn:substring-after($end_point1,',')}"/>,
       <node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
       lon = "{fn:substring-after($end_point2,',')}"/>)) 
       :)
   else 
      (osm:furtherNorthPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>,
       <node visible = 'true' lat = "{geo:x($multilineString2)}" 
       lon = "{geo:y($multilineString2)}"/>))
};

declare function osm:furtherSouthWays($node1 as node(), $node2 as node())
{
  not(osm:furtherNorthWays($node1,$node2))
};

declare function osm:furtherEastWays($oneway1 as node(), $oneway2 as node())
{
  let $multiLineString1 := osm_gml:_osm2GmlLine($oneway1)
  let $multilineString2 := osm_gml:_osm2GmlLine($oneway2)
  let $start_point1 := geo:start-point($multiLineString1/*),
      $end_point1 := geo:end-point($multiLineString1/*)
  return 
    if (geo:dimension($multilineString2) = 1)
    then let $start_point2 := geo:start-point($multilineString2/*),
         $end_point2 := geo:end-point($multilineString2/*)
    return 
       (osm:furtherEastPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>, 
       <node visible = 'true' lat = "{fn:substring-before($start_point2,',')}" 
       lon = "{fn:substring-after($start_point2,',')}"/>) )
       and (osm:furtherEastPoints(
       <node visible = 'true' lat = "{fn:substring-before($end_point1,',')}" 
       lon = "{fn:substring-after($end_point1,',')}"/>, 
       <node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
       lon = "{fn:substring-after($end_point2,',')}"/>) )      
   else 
       (osm:furtherEastPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>,
       <node visible = 'true' lat = "{geo:x($multilineString2)}" 
       lon = "{geo:x($multilineString2)}"/>))
};

declare function osm:furtherWestWays($node1 as node(), $node2 as node())
{
  not(osm:furtherEastWays($node1,$node2))
};

declare function osm:getOneWay($document as node()*, $string as xs:string)
{
  fn:filter(rt:getLayerByName($document,$string), osm:searchTags(?,$string)) 
}; 

declare function osm:isInGeometry($oneway1 as node(), $oneway2 as node())
{
 (osm:getDistanceBetweenGeometries($oneway1, $oneway2) < 0.0001)  
};

declare function osm:isNextToGeometry($oneway1 as node(), $oneway2 as node())
{
 (osm:getDistanceBetweenGeometries($oneway1, $oneway2) < 0.001) 
};

declare function osm:isAwayFromGeometry($oneway1 as node(), $oneway2 as node())
{
 (osm:getDistanceBetweenGeometries($oneway1, $oneway2) < 0.01) 
};




