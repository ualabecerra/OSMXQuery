module namespace osm_solap = "osm_solap";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';

(: Spatial-Miltidimensional Distributive Operators :)

declare function osm_solap:topologicalCount($document as node()*, $oneway as node(), 
$topologicalRelation as xs:string)
{
 count(fn:filter($document,osm:booleanQuery(?, $oneway, $topologicalRelation))) 
};

declare function osm_solap:metricMin($document as node()*, $metricOperator 
as xs:string)
{
 let $list := osm_solap:metricList($document,$metricOperator),
     $minValue := fn:min(data($list/tag[@k=$metricOperator]/@v))
 return                         
     fn:filter($list, function($oneway) 
               {$oneway/tag[@k = $metricOperator]/@v = $minValue})
};

declare function osm_solap:metricMax($document as node()*, $metricOperator as xs:string)
{
 let $list := osm_solap:metricList($document,$metricOperator),
     $maxValue := fn:max(data($list/tag[@k=$metricOperator]/@v))
 return
     fn:filter($list, function($oneway) 
               {$oneway/tag[@k = $metricOperator]/@v = $maxValue})
};

declare function osm_solap:metricSum($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
     fn:sum(fn:for-each($document,$metricFunction(?)))    
};

declare function osm_solap:minDistance($document as node()*)
{
  fn:sort($document,function($oneway){$oneway/@distance})[1] 
};

declare function osm_solap:maxDistance($document as node()*)
{
  fn:sort($document,function($oneway){-($oneway/@distance)})[1]
};

(: Spatial-Multidimensional Algebraic Operators:)

declare function osm_solap:metricList($document as node()*, $metricOperator 
as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  for $oneway in $document
  return 
    osm:addTagMode($oneway,$metricOperator,xs:string($metricFunction($oneway))) 
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
  let $list := osm_solap:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, function($oneway)
                {xs:double($oneway/tag[@k=$metricOperator]/@v)}),1,$k) 
};

declare function osm_solap:metricTopCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := osm_solap:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, function($oneway)
                {-(xs:double($oneway/tag[@k=$metricOperator]/@v))}),1,$k)
};

declare function osm_solap:bottomCountDistance($document as node()*,$k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){$oneway/@distance}),1,$k)
};

declare function osm_solap:topCountDistance($document as node()*, $k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){-($oneway/@distance)}),1,$k)
};

(: Spatial-Multidimensional Holistic Operators :)

declare function osm_solap:metricMedian($document as node()*, $metricOperator as xs:string)
{
  let $list := osm_solap:metricList($document,$metricOperator),
      $orderedList := fn:sort($list/*, function($oneway){
                         $oneway/tag[@k=$metricOperator]/@v }),
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
 let $list := osm_solap:mode_aux($document,$metricOperator),
     $maxValue := fn:max(data($list/tag[@k="osm:occurrences"]/@v))
 return
    fn:filter($list, function($oneway) 
               {$oneway/tag[@k="osm:occurrences"]/@v  = $maxValue})
};

declare function osm_solap:metricRank($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := osm_solap:metricList($document,$metricOperator)
  return fn:sort($list, function($oneway)
                {xs:double($oneway/tag[@k=$metricOperator]/@v)})[$k]
};

declare function osm_solap:metricRange($document as node()*,
   $metricOperator as xs:string)
{ 
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  let $list := fn:for-each($document,$metricFunction(?)),
       $maxValue := fn:max($list),
       $minValue := fn:min($list)       
  return 
       $maxValue - $minValue
};