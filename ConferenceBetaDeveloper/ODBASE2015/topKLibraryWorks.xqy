module namespace tk = "topK";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

declare function tk:getLayer_mbr_k($document,$mbr, $keywordCollection as xs:string*, 
                  $flag as xs:boolean, $closetDistance as xs:double, $topK as xs:integer)
{
    let $doc := document
    {  $document/rtree/node }
    let $candidates := <candidates mindist="1" maxdist="-1" objects="0">
    </candidates>
    return 
      tk:getLayer_mbr_node_k($doc,$document,$mbr,$keywordCollection,
                             $candidates,$flag,$closetDistance,$topK)
};


declare function tk:getLayer_mbr_node_k($document,$root,$mbr,$keywordCollection as xs:string*, 
                           $candidates, $flag as xs:boolean,
                           $closetDistance as xs:double, $topK as xs:integer)
{

  if ($document/node) then 
   tk:getLayer_each_node_k($document/node,$root,$mbr,$keywordCollection,$candidates,$flag,
                           $closetDistance, $topK)
else 
   if ($document/leaf) then 
     tk:getLayer_each_leaf_k($document/leaf,$root,$mbr,$keywordCollection,$candidates,$flag,$closetDistance,
                             $topK)
   else
    tk:getLayer_each_mbr_k($document/mbr,$root,$mbr,$keywordCollection,$candidates,$flag,$closetDistance,$topK)
};

declare function tk:getLayer_each_node_k($document,$root,$mbr, 
                 $keywordCollection as xs:string*, $candidates, 
                 $flag as xs:boolean, $closetDistance as xs:double, $topK as xs:integer)
{  
 if (empty($document)) then 
   $candidates
 else 
   let $node := head($document)
   let $distanceMBR := tk:getMaxDistTopK($candidates)
   return 
      if ((tk:getNumberObjectsTopK($candidates) < $topK)
       or  
         (tk:minDistanceMBR(xs:float($node/@x),xs:float($node/@y),xs:float($node/@z)
         ,xs:float($node/@t),
          xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),$distanceMBR))
        )
              
   then         
     tk:getLayer_each_node_k(tail($document),$root,$mbr,$keywordCollection,
                            tk:getLayer_mbr_node_k($node,$root,$mbr,$keywordCollection,
                                                   $candidates,$flag,$closetDistance,$topK)
                            ,$flag,$closetDistance,$topK)
   else $candidates                         
};

declare function tk:getLayer_each_leaf_k($document,$root,$mbr, 
                 $keywordCollection as xs:string*, $candidates,
                 $flag as xs:boolean, $closetDistance as xs:double, $topK as xs:integer)
{
   if (empty($document)) then $candidates
   else
   let $node := head($document)
   let $distanceMBR := tk:getMaxDistTopK($candidates)
   return        
     if ((tk:getNumberObjectsTopK($candidates) < $topK)
      or 
        (tk:minDistanceMBR(xs:float($node/@x),xs:float($node/@y),xs:float($node/@z),
        xs:float($node/@t),
        xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),$distanceMBR))
      )
     then
      tk:getLayer_each_leaf_k(tail($document),$root,$mbr,$keywordCollection,
                                tk:getLayer_mbr_node_k($node,$root,$mbr,$keywordCollection,
                                $candidates,$flag,$closetDistance,$topK),
                                $flag,$closetDistance,$topK)
                                
     else $candidates
};

declare function tk:getLayer_each_mbr_k($document,$root,$mbr,
                 $keywordCollection as xs:string*, $candidates, 
                 $flag as xs:boolean, $closetDistance as xs:double, $topK as xs:integer)
{ 
 if (empty($document)) then $candidates 
   else
   let $node := head($document)
   let $distanceMBR := tk:getMaxDistTopK($candidates)
   return  
      if ((tk:getNumberObjectsTopK($candidates) < $topK)
       or      
        (tk:minDistanceMBR(xs:float($node/@x),xs:float($node/@y),xs:float($node/@z),
        xs:float($node/@t), xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),
        $distanceMBR))
      )
    
    then  
       if ($node/mbr/way) then                                   
           
           let $object1 :=
                                <oneway name="{($node/mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $node/mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$node/mbr/*} 
                                </oneway> 
  
           let $object2 :=        
                                <oneway name="{($mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$mbr/*} 
                                </oneway>
   
           let $distance := osm:getDistance($object1,$object2) 

           let $oneway := 
                                <oneway name="{($node/mbr/way)[1]/tag[@k="name"]/@v}" 
                                  distance="{$distance}"> 
                                  {$object1/*} 
                                </oneway>
           return 
              tk:getLayer_each_mbr_k(tail($document),$root,$mbr," ",
                                        tk:addOneWayTopK($candidates, $oneway, $topK),$flag,                                                       $closetDistance,$topK)   
                                                           
        else
                            
             let $object1 :=
                                <oneway  name="node"> 
                                {let $node := for $each in $node/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$node/mbr/*}
                                </oneway> 

             let $object2 := 
                                <oneway name="{($mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$mbr/*} 
                                </oneway> 
  
             let $distance :=            
                                osm:getDistance($object1,$object2)
                                                                
             let $oneway :=         
                               <oneway name="{$node/mbr/node/tag[@k="name"]/@v}" 
                               distance="{$distance}"> 
                               {$object1/*} 
                               </oneway>
             return
                   tk:getLayer_each_mbr_k(tail($document),$root,$mbr," ",
                                         tk:addOneWayTopK($candidates, $oneway, $topK),
                                        $flag,$closetDistance,$topK) 
    else $candidates
                                       
};

declare function tk:minDistanceMBR($x,$y,$z,$t,$a,$b,$c,$d, $distanceMBR)
{
 if (tk:overlap($x,$y,$z,$t,$a,$b,$c,$d)) then true()
 else    let $dist := osm:getDistanceMbr($x,$y,$z,$t,$a,$b,$c,$d)
 return $dist <= $distanceMBR 
};

(: Si dos mbrs solapan :)
declare function tk:overlap($x,$y,$z,$t,$a,$b,$c,$d)
{
 if (($x > $c) or ($a > $z)) then false()
                              else if (($t < $b) or ($d < $y)) then
                              false ()
                              else true() 
};

declare function tk:closestTopKByName($document, $name as xs:string, $topK as xs:integer)
{
  for $mbr in $document//mbr[*/tag/@v=$name]
  return 
    tk:getLayer_mbr_k($document,$mbr," ",true(),0,$topK)
};

declare function tk:closestTopKByElement($document, $oneway, $topK)
{
 tk:closestTopKByName($document,$oneway/@name,$topK)
};

declare function tk:closestTopKWrtNameByKeywords($document, $name as xs:string, 
                  $keywordCollection as xs:string*,$topK as xs:integer)
{
   for $mbr in $document//mbr[*/tag/@v=$name]
   return 
     tk:getLayer_mbr_k($document,$mbr,$keywordCollection,true(),0,$topK)
};

declare function tk:closestTopKWrtElementByKeywords($document, $oneway, 
                  $keywordCollection as xs:string*,$topK as xs:integer)
{
  tk:closestTopKWrtNameByKeywords($document,$oneway/@name,$keywordCollection,$topK)
};

declare function tk:closestDistanceByName($document,
                           $name as xs:string, 
                           $closetDistance as xs:double)
{
  for $mbr in $document//mbr[*/tag/@v=$name]
  return 
    tk:getLayer_mbr_k($document,$mbr," ", false(),$closetDistance,0) 
};

declare function tk:closestDistanceByElement($document, 
                           $oneway, 
                           $closetDistance as xs:double)
{
 tk:closestDistanceByName($document,$oneway/@name,$closetDistance)
};

declare function tk:closestDistanceWrtNameByKeywords($document, 
                  $name as xs:string, 
                  $keywordCollection as xs:string*,
                  $closetDistance as xs:double)
{
   for $mbr in $document//mbr[*/tag/@v=$name]
   return 
    tk:getLayer_mbr_k($document,$mbr,$keywordCollection,false(),$closetDistance,0) 
};

declare function tk:closestDistanceWrtElementByKeywords($document, 
                  $oneway, 
                  $keywordCollection as xs:string*,
                  $closetDistance as xs:double)
{
  tk:closestDistanceWrtNameByKeywords($document,$oneway/@name,$keywordCollection,$closetDistance)
};

declare function tk:closestElementByCollection($onewayRef,
             $collectionElements)
{
 let $document := 
 <doc>
 { for $oneway in $collectionElements/*
  return 
   let $distance := osm:getDistance($onewayRef,$oneway)
   return  
      <oneway name = "{$oneway/@name}" distance1 = "{$oneway/@distance}" 
      distance2 =  "{$distance}" > {$oneway/*} </oneway>
  }
  </doc>
  return 
   let $doc := 
   <doc>
   { for $onewayResult in $document/*
   order by number($onewayResult/@distance2)
   return 
     $onewayResult
  }
  </doc>
  return fn:subsequence($doc/*,1,1) 
};

declare function tk:getMinDistTopK($candidates)
{
 xs:double(data($candidates/@mindist))
};

declare function tk:getMaxDistTopK($candidates)
{
 xs:double(data($candidates/@maxdist))
};

declare function tk:getNumberObjectsTopK($candidates)
{
 xs:integer(data($candidates/@objects))
};

declare function tk:addCandidate($candidates, $oneway, $mindist, 
                                 $numberObjects, $flag as xs:boolean)
{
  (
  let $document := 
    <doc>
    {
    (for $oneways in $candidates/oneway
     return $oneways
     )
     union 
      (
      $oneway         
     )
    }
    </doc>
  
  let $doc := 
       for $cand in $document/*
       order by number($cand/@distance)
       return $cand 
       
  return 
      <candidates mindist = "{$mindist}" maxdist = "{$doc[$numberObjects]/@distance}" 
      objects = "{$numberObjects}">
       {
         if ($flag) then 
            remove($doc,$numberObjects+1) 
         else $doc
       } 
      </candidates>)
    };

declare function tk:addKeywordTopK($candidates as node(), $oneway as node(), 
                 $keywordCollection as xs:string*,$topK as xs:integer)
{
  if (osm:searchTags($oneway,$keywordCollection))
   then tk:addOneWayTopK($candidates, $oneway, $topK)
   else $candidates
};

declare function tk:addOneWayTopK($candidates, $oneway, $topK as xs:integer)
{
  if (tk:getNumberObjectsTopK($candidates) < $topK)
  then
     if (tk:getMinDistTopK($candidates) > $oneway/@distance)
      then tk:addCandidate($candidates, $oneway, $oneway/@distance,  
                           tk:getNumberObjectsTopK($candidates)+1, false())
      else tk:addCandidate($candidates,$oneway,tk:getMinDistTopK($candidates), 
                           tk:getNumberObjectsTopK($candidates)+1,false())
  else 
     if (tk:getMaxDistTopK($candidates) < $oneway/@distance) 
       then $candidates
       else
          if (tk:getMinDistTopK($candidates) > $oneway/@distance)
          then tk:addCandidate($candidates,$oneway,$oneway/@distance,  
                               tk:getNumberObjectsTopK($candidates),true())
          else tk:addCandidate($candidates,$oneway,tk:getMinDistTopK($candidates),
                               tk:getNumberObjectsTopK($candidates),true())
};

declare function tk:addKeywordDistance($candidates, $oneway, 
                 $keywordCollection as xs:string*, $closetDistance as xs:double)
{
  if (osm:searchTags($oneway,$keywordCollection))
   then tk:addOneWayDistance($candidates, $oneway, $closetDistance)
   else $candidates
};

declare function tk:addOneWayDistance($candidates, $oneway, $closetDistance as xs:double)
{
 if ($oneway/@distance > $closetDistance)
  then $candidates 
 else 
   if (tk:getMinDistTopK($candidates) > $oneway/@distance)
      then tk:addCandidate($candidates, $oneway, $oneway/@distance, 
           tk:getNumberObjectsTopK($candidates)+1, false())
   else tk:addCandidate($candidates,$oneway,tk:getMinDistTopK($candidates), 
              tk:getNumberObjectsTopK($candidates)+1,false())
};