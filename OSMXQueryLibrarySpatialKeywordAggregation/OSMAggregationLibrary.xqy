module namespace osm_aggr = "osm_aggr";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';

(: Auxiliary Operators :)

declare function osm_aggr:addAggregationTag($oneway as node(), $kValueToAdd as xs:string, $vValueToAdd as xs:string)
{
  let $name := $oneway//tag[@k="name"]/@v
  let $distance := $oneway/@distance
  return
  <oneway name = "{$name}" distance = "{$distance}">
    { (for $tag in $oneway/*
       return ($tag)
      ) union <tag k='{$kValueToAdd}' v='{$vValueToAdd}' /> }
  </oneway>
};

declare function osm_aggr:auxiliaryMode($document as node()*,$metricOperator as xs:string)
{
  let $list := osm_aggr:metricList($document,$metricOperator) 
  return 
  for $oneway in $list
  let $value := data($oneway/tag[@k=$metricOperator]/@v)
  return
  let $grouping := 
  <group name = '{$value}'>
 {   
   for $oneway2 in $list
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
     for $oneway in $list
        where
         ($oneway//tag/@k = "name") and ($oneway//tag/@v = $group2//tag[@k="name"]/@v) 
        return 
           osm_aggr:addAggregationTag($oneway,"osm:occurrences",xs:string(count($group2/*))) 
};

(: Spatial-Miltidimensional Distributive Operators :)

declare function osm_aggr:topologicalCount($document as node()*, $oneway as node(), 
$topologicalRelation as xs:string)
{
 count(fn:filter($document,osm:booleanQuery(?, $oneway, $topologicalRelation))) 
};

declare function osm_aggr:metricMin($document as node()*, $metricOperator 
as xs:string)
{
 let $list := osm_aggr:metricList($document,$metricOperator),
     $minValue := fn:min(data($list/tag[@k=$metricOperator]/@v))
 return        
     fn:filter($list, osm:searchTag(?,$metricOperator,$minValue))                 
};

declare function osm_aggr:metricMax($document as node()*, $metricOperator as xs:string)
{
 let $list := osm_aggr:metricList($document,$metricOperator),
     $maxValue := fn:max(data($list/tag[@k=$metricOperator]/@v))
 return     
     fn:filter($list, osm:searchTag(?,$metricOperator,$maxValue))
};

declare function osm_aggr:metricSum($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
     fn:sum(fn:for-each($document,$metricFunction(?)))    
};

declare function osm_aggr:minDistance($document as node()*)
{
 fn:sort($document,function($oneway){osm:getDistance($oneway)})[1]
};

declare function osm_aggr:maxDistance($document as node()*)
{
 fn:sort($document,function($oneway){-osm:getDistance($oneway)})[1]
};

(: Spatial-Multidimensional Algebraic Operators:)

declare function osm_aggr:metricList($document as node()*, $metricOperator 
as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
  fn:for-each($document, function($oneway)
     {osm_aggr:addAggregationTag($oneway,$metricOperator,xs:string($metricFunction($oneway)))})
};

declare function osm_aggr:metricAvg($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
   fn:avg(fn:for-each($document,$metricFunction(?)))    
};

declare function osm_aggr:avgDistance($document as node()*)
{
  fn:avg(fn:for-each($document,osm:getDistance(?)))    
};

declare function osm_aggr:metricBottomCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := osm_aggr:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, 
         function($oneway){osm:getTagValue(?,$metricOperator)}),1,$k)             
};

declare function osm_aggr:metricTopCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := osm_aggr:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, 
         function($oneway){-osm:getTagValue($oneway,$metricOperator)}),1,$k)
};

(: ********************************************* Aquí sigo ******************** :)

declare function osm_aggr:bottomCountDistance($document as node()*,$k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){$oneway/@distance}),1,$k)
};

declare function osm_aggr:topCountDistance($document as node()*, $k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){-($oneway/@distance)}),1,$k)
};

(: Spatial-Multidimensional Holistic Operators :)

declare function osm_aggr:metricMedian($document as node()*, $metricOperator as xs:string)
{
  let $list := osm_aggr:metricList($document,$metricOperator),
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

declare function osm_aggr:metricMode($document as node()*,$metricOperator as xs:string)
{
 let $list := osm_aggr:auxiliaryMode($document,$metricOperator), 
     $maxValue := fn:max(data($list/tag[@k="osm:occurrences"]/@v))
 return 
   let $documentResult := fn:filter($list, function($oneway) 
               {$oneway/tag[@k="osm:occurrences"]/@v  = $maxValue})
   let $onewayNames :=  distinct-values(data($documentResult/@name))        
   for $onewayName in $onewayNames
   return $documentResult[@name=$onewayName][1]
};

declare function osm_aggr:metricRank($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := osm_aggr:metricList($document,$metricOperator)
  return fn:sort($list, function($oneway)
                {xs:double($oneway/tag[@k=$metricOperator]/@v)})[$k]
};

declare function osm_aggr:metricRange($document as node()*,
   $metricOperator as xs:string)
{ 
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  let $list := fn:for-each($document,$metricFunction(?)),
       $maxValue := fn:max($list),
       $minValue := fn:min($list)       
  return 
       $maxValue - $minValue
};