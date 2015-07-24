module namespace xosm_ag = "xosm_ag";

import module namespace xosm_sp = "xosm_sp" at "XOSMSpatialQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "XOSMKeywordQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

declare namespace gml='http://www.opengis.net/gml';

(: Auxiliary Operators :)

declare function xosm_ag:addAggregationTag($oneway as node(), $kValueToAdd as xs:string, $vValueToAdd as xs:string)
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

declare function xosm_ag:auxiliaryMode($document as node()*,$metricOperator as xs:string)
{
  let $list := xosm_ag:metricList($document,$metricOperator) 
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
           xosm_ag:addAggregationTag($oneway,"osm:occurrences",xs:string(count($group2/*))) 
};

(: Spatial-Miltidimensional Distributive Operators :)

declare function xosm_ag:topologicalCount($document as node()*, $oneway as node(), 
$topologicalRelation as xs:string)
{
 count(fn:filter($document,xosm_sp:booleanQuery(?, $oneway, $topologicalRelation))) 
};

declare function xosm_ag:metricMin($document as node()*, $metricOperator 
as xs:string)
{
 let $list := xosm_ag:metricList($document,$metricOperator),
     $minValue := fn:min(data($list/tag[@k=$metricOperator]/@v))
 return        
     fn:filter($list, xosm_kw:searchTag(?,$metricOperator,$minValue))                 
};

declare function xosm_ag:metricMax($document as node()*, $metricOperator as xs:string)
{
 let $list := xosm_ag:metricList($document,$metricOperator),
     $maxValue := fn:max(data($list/tag[@k=$metricOperator]/@v))
 return     
     fn:filter($list, xosm_kw:searchTag(?,$metricOperator,$maxValue))
};

declare function xosm_ag:metricSum($document as node()*,$metricOperator as xs:string)
{
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
     fn:sum(fn:for-each($document,$metricFunction(?)))    
};

declare function xosm_ag:minDistance($document as node()*)
{
  
(: Modificar aquí con keyword de switch:)  
 fn:sort($document,function($oneway){xosm_sp:getDistance($oneway)})[1]
};

declare function xosm_ag:maxDistance($document as node()*)
{
 (: Modificar aquí con keyword de switch:)  
 fn:sort($document,function($oneway){-xosm_sp:getDistance($oneway)})[1]
};

(: Spatial-Multidimensional Algebraic Operators:)

declare function xosm_ag:metricList($document as node()*, $metricOperator 
as xs:string)
{
  (: Modificar aquí con keyword de switch:) 
  
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
  fn:for-each($document, function($oneway)
     {xosm_ag:addAggregationTag($oneway,$metricOperator,xs:string($metricFunction($oneway)))})
};

declare function xosm_ag:metricAvg($document as node()*,$metricOperator as xs:string)
{
  (: Modificar aquí con keyword de switch:) 
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  return
   fn:avg(fn:for-each($document,$metricFunction(?)))    
};

declare function xosm_ag:avgDistance($document as node()*)
{
 (: Modificar aquí con keyword de switch y poner function :)  
  fn:avg(fn:for-each($document,xosm_sp:getDistance(?)))    
};

declare function xosm_ag:metricBottomCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := xosm_ag:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, 
         function($oneway){xosm_kw:getTagValue($oneway,$metricOperator)}),1,$k)             
};

declare function xosm_ag:metricTopCount($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := xosm_ag:metricList($document,$metricOperator)
  return fn:subsequence(fn:sort($list, 
         function($oneway){-xosm_kw:getTagValue($oneway,$metricOperator)}),1,$k)
};

(: ********************************************* Aquí sigo ******************** :)

declare function xosm_ag:bottomCountDistance($document as node()*,$k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){$oneway/@distance}),1,$k)
};

declare function xosm_ag:topCountDistance($document as node()*, $k as xs:integer)
{
 fn:subsequence(fn:sort($document,function($oneway){-($oneway/@distance)}),1,$k)
};

(: Spatial-Multidimensional Holistic Operators :)

declare function xosm_ag:metricMedian($document as node()*, $metricOperator as xs:string)
{
  let $list := xosm_ag:metricList($document,$metricOperator),
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

declare function xosm_ag:metricMode($document as node()*,$metricOperator as xs:string)
{
 let $list := xosm_ag:auxiliaryMode($document,$metricOperator), 
     $maxValue := fn:max(data($list/tag[@k="osm:occurrences"]/@v))
 return 
   let $documentResult := fn:filter($list, function($oneway) 
               {$oneway/tag[@k="osm:occurrences"]/@v  = $maxValue})
   let $onewayNames :=  distinct-values(data($documentResult/@name))        
   for $onewayName in $onewayNames
   return $documentResult[@name=$onewayName][1]
};

declare function xosm_ag:metricRank($document as node()*, 
$metricOperator as xs:string, $k as xs:integer)
{
  let $list := xosm_ag:metricList($document,$metricOperator)
  return fn:sort($list, function($oneway)
                {xs:double($oneway/tag[@k=$metricOperator]/@v)})[$k]
};

declare function xosm_ag:metricRange($document as node()*,
   $metricOperator as xs:string)
{ 
  let $metricFunction := fn:function-lookup(xs:QName($metricOperator),1)
  let $list := fn:for-each($document,$metricFunction(?)),
       $maxValue := fn:max($list),
       $minValue := fn:min($list)       
  return 
       $maxValue - $minValue
};