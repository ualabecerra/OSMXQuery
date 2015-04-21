module namespace osm_solap = "osm_solap";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';

declare function osm_solap:tableComposer($document)
{
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="en" lang="en"> 
<head> 
 <title>Geo-Analytics on OpenStreetMap Road Data | BeyoBlog</title> 
  <link rel='stylesheet' type='text/css' href='./styles/main.css' />
 </head> 
<body>
 <table dir="ltr" border = "0" cellspacion = "0" cellpadding = "0"
  witdh = "700" height = "1"> 
 <trbody>
<td align="right" width="75" height="30"  valign="Bottom" style='height:15.0pt;  padding-left:1.5pt;padding-right:2.0pt;padding-top:1.5pt;padding-bottom:1.5pt;  border-top:solid black .5pt'><span style="font-size: 11px;italic;"><i>Version</i></span>
</td>
</trbody>
 </table> 
</body>
</html>
};

declare function osm_solap:globalStatisctic($document)
{
 count($document/*/way)
};

(: Spatial-Miltidimensional Distributive Operators :)

declare function osm_solap:topologicalCount($document as node()*, $oneway as node(), 
$topologicalRelation as xs:string)
{
 count(fn:filter($document,osm:booleanQuery(?, $oneway, $topologicalRelation))) 
};

declare function osm_solap:metricMin($document as node()*, $metricOperator 
as xs:string)
{
 let $list := 
     osm_solap:metricList($document,$metricOperator)/*,
     $minValue := fn:min(data($list/tag[@k=$metricOperator]/@v))
 for $oneway in $list
 where ($oneway/tag[@k = "osm:getDistance"]/@v = $minValue)
 (: where ($oneway/tag/@k = $metricOperator) and ($oneway/tag/@v = $minValue):)
 return $oneway
};

declare function osm_solap:metricMax($document as node()*, $metricOperator as xs:string)
{
 let $list := 
      osm_solap:metricList($document,$metricOperator)/*,
      $maxValue := fn:max(data($list/tag[@k=$metricOperator]/@v))
 return
 for $oneway in $list
 where  ($oneway/tag/@k = $metricOperator) and ($oneway/tag/@v = $maxValue)
 return $oneway 
(: where   ($oneway/tag[@k = "osm:getArea"]/@v = $maxValue) :)
};

declare function osm_solap:metricSum($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
   fn:sum(fn:for-each($document,$metricFunction(?)))    
};

declare function osm_solap:minDistance($document as node()*)
{
  let $result :=   
    for $oneway in $document   
    order by $oneway/@distance ascending
    return $oneway
  return $result[1]
};

declare function osm_solap:maxDistance($document as node()*)
{
  let $result :=   
    for $oneway in $document   
    order by $oneway/@distance descending
    return $oneway
  return $result[1]
};

declare function osm_solap:count($document as node()*)
{
 fn:count($document)    
};

(: Spatial-Multidimensional Algebraic Operators:)

declare function osm_solap:metricList($document as node()*, $metricOperator 
as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
  <list>
  {
   for $oneway in $document
   return 
    osm:addTagMode($oneway,$metricOperator,xs:string($metricFunction($oneway))) 
  }
  </list>       
};

declare function osm_solap:metricAvg($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
   fn:avg(fn:for-each($document,$metricFunction(?)))    
};

declare function osm_solap:avgDistance($document as node()*)
{
 fn:avg(fn:for-each($document,osm:getDistance(?)))    
};

declare function osm_solap:metricBottomCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $result :=   
    for $oneway in osm_solap:metricList($document,$metricOperator)/*   
    order by xs:double($oneway/tag[@k=$metricOperator]/@v) ascending
    return $oneway
  return fn:subsequence($result,1,$k)
};

declare function osm_solap:metricTopCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $result :=   
    for $oneway in osm_solap:metricList($document,$metricOperator)/*   
    order by xs:double($oneway/tag[@k=$metricOperator]/@v) descending
    return $oneway
  return fn:subsequence($result,1,$k)
};

declare function osm_solap:bottomCountDistance($document as node()*, $k as xs:integer)
{
  let $result :=   
    for $oneway in $document   
    order by $oneway/@distance ascending
    return $oneway
  return fn:subsequence($result,1,$k)
};

declare function osm_solap:topCountDistance($document as node()*, $k as xs:integer)
{
  let $result :=   
    for $oneway in $document   
    order by $oneway/@distance descending
    return $oneway
  return fn:subsequence($result,1,$k)
};

(: Spatial-Multidimensional Holistic :)


(: Spatial-Multidimensional Holistic Operators :)

declare function osm_solap:metricMedian($document as node()*, $metricOperator as xs:string)
{
  let $list := osm_solap:metricList($document,$metricOperator),
      $orderedList := fn:sort($list/*, function($oneway){
                         $oneway/tag[@k=$metricOperator]/@v }),
(:      $orderedList := fn:sort($document,$indicatorFunction(?)) :)
      $count := count($orderedList)
  return 
    if ($count mod 2 != 0) then
      $orderedList[xs:integer($count div 2)+1]
    else 
      ($orderedList[$count div 2]/tag[@k=$metricOperator]/@v 
      + $orderedList[($count div 2) + 1]/tag[@k=$metricOperator]/@v) div 2
};

declare function osm_solap:mode_aux($document as node()*,$metricOperator as xs:string)
{
  let $list := osm_solap:metricList($document,$metricOperator) 

  for $oneway in $list/*
  let $value := data($oneway/tag[@k=$metricOperator]/@v)
  return 
  let $grouping := 
  <group name = '{$value}'>
 {   
   for $oneway2 in $list/*
   where ($oneway2/tag/@k = $metricOperator) and (data($oneway2/tag/@v) = $value)
   let $result := $oneway2
   return $oneway2
  }
 </group>
 return 
    let $groupDef := 
      for $group in $grouping
      where $group/@name != "-1"
      return $group
   for $group2 in $groupDef
    return       
     for $oneway in $list/*
        where
         ($oneway//tag/@k = "name") and ($oneway//tag/@v = $group2//tag[@k="name"]/@v) 
        return 
           osm:addTagMode($oneway,"osm:occurrences",xs:string(count($group2/*)))
};

declare function osm_solap:metricMode($document as node()*,$metricOperator as xs:string)
{
   let $list := osm_solap:mode_aux($document,$metricOperator)
   return
   let $maxValue := fn:max(data($list/tag[@k="osm:occurrences"]/@v))
   return
    for $oneway in $list
      where ($oneway/tag[@k="osm:occurrences"]/@v)  = $maxValue
      return 
          $oneway
};

declare function osm_solap:metricRank($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $result :=   
    for $oneway in osm_solap:metricList($document,$metricOperator)/*   
    order by xs:double($oneway/tag[@k=$metricOperator]/@v) ascending
    return $oneway
  return $result[$k]
};

declare function osm_solap:metricRange($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
   let $list := fn:for-each($document,$metricFunction(?)),
       $maxValue := fn:max($list),
       $minValue := fn:min($list)       
  return 
       $maxValue - $minValue
};