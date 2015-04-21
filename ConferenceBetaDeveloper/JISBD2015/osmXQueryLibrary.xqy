module namespace osm = "osm";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

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
 $onewayResult1 intersect $onewayResult2
};

declare function osm:exceptQuery($onewayResult1 as node()*, $onewayResult2 as node()*)
{
 $onewayResult1 except $onewayResult2
};


(:                           Keyword Operators                                :)
(: ************************************************************************ :)


declare function osm:addTag($oneway as node(), $kValueToAdd as xs:string, $vValueToAdd as xs:double)
{
  let $name := $oneway/@name
    return
    <oneway name = "{$name}">
    {
      (for $element in $oneway/* 
        return 
            for $item in $oneway/*[name(.)='way']
            let $idValue := $item/@id
            return 
            <way id = "{$idValue}" visible = 'true' version = '6'>
             { 
              (for $tag in $item/*
                return ($tag)
              )
              union <tag k='{$kValueToAdd}' v='{$vValueToAdd}' />
            } </way>
       ) 
       union (for $nodeid in $oneway/*[name(.)='node']
              return $nodeid)
       union <tag k='{$kValueToAdd}' v='{$vValueToAdd}' />
    }
    </oneway>
};

declare function osm:addTagMode($oneway as node(), $kValueToAdd as xs:string, $vValueToAdd as xs:string)
{
  let $name := $oneway//tag[@k="name"]/@v
  let $distance := $oneway/@distance
  return
    <oneway name = "{$name}" distance = "{$distance}">
    {
      (for $tag in $oneway/*
       return ($tag)
      )
      union <tag k='{$kValueToAdd}' v='{$vValueToAdd}' /> 
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
    return 
            (geo:equals($intersection_point/*,$start_point/*) or 
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

declare function osm:intersectionPoint($oneway1 as node(), $oneway2 as node())
{
  let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
        $multiLineString2 := osm_gml:_osm2GmlLine($oneway2)
    return
      let $intersectionPoint := geo:intersection($mutliLineString1,$multiLineString2)
         let $values :=  data($intersectionPoint/*/*[1])
     return
      if ($intersectionPoint//gml:LineString)
       then
         let $values2 := fn:substring-after($values,' ')
         return  
         <oneway name = "intersectionPoint">
         <node visible = "true" lat = "{fn:substring-before($values2,',')}" 
         lon = "{fn:substring-after($values2,',')}"/>
       </oneway>
       else
         <oneway name = "intersectionPoint">
         <node visible = "true" lat = "{fn:substring-before($values,',')}" 
         lon = "{fn:substring-after($values,',')}"/>
       </oneway>
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
        if (
        (osm:furtherNorthPoints( 
         <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
         lon = "{fn:substring-after($start_point1,',')}"/>, 
         <node visible = 'true' lat = "{fn:substring-before($start_point2,',')}" 
         lon = "{fn:substring-after($start_point2,',')}"/>) )
         and (osm:furtherNorthPoints( 
         <node visible = 'true' lat = "{fn:substring-before($end_point1,',')}" 
         lon = "{fn:substring-after($end_point1,',')}"/>,
         <node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
         lon = "{fn:substring-after($end_point2,',')}"/>))
         )
        then geo:distance($multiLineString1,$multilineString2) 
        else -1 
   else 
       if (
         (osm:furtherNorthPoints(
         <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
         lon = "{fn:substring-after($start_point1,',')}"/>,
         <node visible = 'true' lat = "{geo:x($multilineString2)}" 
         lon = "{geo:x($multilineString2)}"/>))
       )
       then geo:distance($multiLineString1,$multilineString2)
       else -1
};

declare function osm:furtherSouthWays($oneway1 as node(), $oneway2 as node())
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
        if (
        (osm:furtherSouthPoints( 
         <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
         lon = "{fn:substring-after($start_point1,',')}"/>, 
         <node visible = 'true' lat = "{fn:substring-before($start_point2,',')}" 
         lon = "{fn:substring-after($start_point2,',')}"/>) )
         and (osm:furtherSouthPoints( 
         <node visible = 'true' lat = "{fn:substring-before($end_point1,',')}" 
         lon = "{fn:substring-after($end_point1,',')}"/>,
         <node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
         lon = "{fn:substring-after($end_point2,',')}"/>))
         )
        then geo:distance($multiLineString1,$multilineString2) 
        else -1 
   else 
       if (
         (osm:furtherSouthPoints(
         <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
         lon = "{fn:substring-after($start_point1,',')}"/>,
         <node visible = 'true' lat = "{geo:x($multilineString2)}" 
         lon = "{geo:x($multilineString2)}"/>))
         )
       then geo:distance($multiLineString1,$multilineString2) 
       else -1
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
      if (
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
       )
      then geo:distance($multiLineString1,$multilineString2)
      else -1     
   else 
      if (
       (osm:furtherEastPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>,
       <node visible = 'true' lat = "{geo:x($multilineString2)}" 
       lon = "{geo:x($multilineString2)}"/>))
       )
      then geo:distance($multiLineString1,$multilineString2)
      else -1
};

declare function osm:furtherWestWays($oneway1 as node(), $oneway2 as node())
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
      if (
       (osm:furtherWestPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>, 
       <node visible = 'true' lat = "{fn:substring-before($start_point2,',')}" 
       lon = "{fn:substring-after($start_point2,',')}"/>) )
       and (osm:furtherWestPoints(
       <node visible = 'true' lat = "{fn:substring-before($end_point1,',')}" 
       lon = "{fn:substring-after($end_point1,',')}"/>, 
       <node visible = 'true' lat = "{fn:substring-before($end_point2,',')}" 
       lon = "{fn:substring-after($end_point2,',')}"/>) )  
       )
      then geo:distance($multiLineString1,$multilineString2)
      else -1     
   else 
      if (
       (osm:furtherWestPoints(
       <node visible = 'true' lat = "{fn:substring-before($start_point1,',')}" 
       lon = "{fn:substring-after($start_point1,',')}"/>,
       <node visible = 'true' lat = "{geo:x($multilineString2)}" 
       lon = "{geo:x($multilineString2)}"/>))
       )
      then geo:distance($multiLineString1,$multilineString2)
      else -1
};

(: Returns the shortest distance between two ways, 
   where that distance is the distance between a point on each of the geometries :)
   
declare function osm:getDistance($oneway1 as node(), $oneway2 as node())
{
  let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
      $multiLineString2 := osm_gml:_osm2GmlLine($oneway2)
  return
    geo:distance($mutliLineString1,$multiLineString2)
};

declare function osm:getDistanceMbr($x1 as xs:float, $y1 as xs:float, 
                                    $s1 as xs:float, $t1 as xs:float,
                                    $x2 as xs:float, $y2 as xs:float, 
                                    $s2 as xs:float, $t2 as xs:float)
{
  let $oneway1 := <oneway name = "node">
                  <way name = "way"/>
                  <node visible="true" lat = "{$x1}" lon = "{$y1}" />
                  <node visible="true" lat = "{$s1}" lon = "{$y1}" />
                  <node visible="true" lat = "{$s1}" lon = "{$t1}" />
                  <node visible="true" lat = "{$x1}" lon = "{$t1}" />
                  <node visible="true" lat = "{$x1}" lon = "{$y1}" />
                  </oneway>
  
  let $oneway2 := <oneway name = "node">
                  <way name = "way"/>
                  <node visible="true" lat = "{$x2}" lon = "{$y2}" />
                  <node visible="true" lat = "{$s2}" lon = "{$y2}" />
                  <node visible="true" lat = "{$s2}" lon = "{$t2}" />
                  <node visible="true" lat = "{$x2}" lon = "{$t2}" />
                  <node visible="true" lat = "{$x2}" lon = "{$y2}" />
                  </oneway> 
                  
  let $mutliLineString1 := osm_gml:_osm2GmlLine($oneway1), 
      $multiLineString2 := osm_gml:_osm2GmlLine($oneway2)
  return
      geo:distance($mutliLineString1,$multiLineString2) 
};
 
declare function osm:isIn($oneway1 as node(), $oneway2 as node())
{
 let $distance := osm:getDistance($oneway1, $oneway2)
 return 
   if ($distance < 0.0001)
   then $distance
   else -1
};

declare function osm:isNext($oneway1 as node(), $oneway2 as node())
{
 let $distance := osm:getDistance($oneway1, $oneway2)
 return 
   if ($distance < 0.001 and $distance > 0.0001)
   then $distance
   else -1 
};

declare function osm:isAway($oneway1 as node(), $oneway2 as node())
{
 let $distance := osm:getDistance($oneway1,$oneway2)
 return
   if ($distance < 0.01 and $distance > 0.001)
   then $distance
   else -1
    
};

declare function osm:getLength($oneway as node())
{
 (geo:length(osm_gml:_osm2GmlLine($oneway))) * 10000
};

declare function osm:getArea($oneway as node())
{
 (geo:area(osm_gml:_osm2GmlPolygon($oneway)) * (3.14 div 180) * 6378137) * 10000
};

declare function osm:getHotelStars($oneway as node())
{
 if ($oneway//tag[@k="stars"]) then
  $oneway//tag[@k="stars"]/@v
 else 
  xs:string(-1)
};

declare function osm:getDistance($oneway as node())
{
 $oneway/@distance
};

declare function osm:getRestaurantCuisine($oneway as node())
{
 if ($oneway//tag[@k="cuisine"]) then
  $oneway//tag[@k="cuisine"]/@v
 else 
  xs:string(-1)
};


