module namespace gl = "getLayer";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy"; 

declare function gl:getLayer_mbr($document,$mbr,$distance)
{
    let $doc := document
    {  $document/rtree/node }
    return
     gl:getLayer_mbr_node($doc,$document,$mbr,$distance)
    
};

declare function gl:getLayer_mbr_node($document,$root,$mbr,$distance)
{
 
if ($document/node) then  for $node in $document/node
                              
                                where (:AQUI:)
                                gl:overlap(
                                  xs:float($node/@x),xs:float($node/@y),xs:float($node/@z),xs:float($node/@t),
                                  xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),
                                  $distance)
                                
                                return  gl:getLayer_mbr_node($node,$root,$mbr,$distance)
                                else  
                                for $leaf in $document/leaf
                                where gl:overlap(
                                  xs:float($leaf/@x),xs:float($leaf/@y),xs:float($leaf/@z),xs:float($leaf/@t),
                                  xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),
                                  $distance)
                                
                                
                                return for $way in $leaf/mbr 
                                where gl:overlap(
                                  xs:float($way/@x),xs:float($way/@y),xs:float($way/@z),xs:float($way/@t),
                                  xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),
                                  $distance)
                                 
                                return 
                                
  if ($way/mbr/way) then 
   let $object1 :=
                                <oneway name="{($way/mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $way/mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$way/mbr/*} 
                                </oneway> 
  
  let $object2 :=               <oneway name="{($mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$mbr/*} 
                                </oneway>
   
  let $distance := osm:getDistance($object1,$object2)

      return

      <oneway name="{($way/mbr/way)[1]/tag[@k="name"]/@v}" distance="{$distance}"> 
                                {$object1/*} 
      </oneway>

     else 

    let $object1 :=
                  <oneway  name="node"> 
                  {let $node := for $each in $way/mbr/way/nd return
                   $root/rtree/nodes/node[@id=$each/@ref] return $node}
                   {$way/mbr/*}
                   </oneway> 
 

     let $object2 := <oneway name="{($mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$mbr/*} 
                   </oneway> 
   

  (:  <oneway>{$mbr/*}</oneway> :)
  
  return 
  
   let $distance:= osm:getDistance($object1,$object2)                                
  
   return
          <oneway name="{($way/mbr/way)[1]/tag[@k="name"]/@v}" distance="{$distance}"> 
                  {$object1/*} 
          </oneway>

};

declare function gl:overlap($x,$y,$z,$t,$a,$b,$c,$d,$distance)
{
 if (gl:overlap_old($x,$y,$z,$t,$a,$b,$c,$d)) then true()
 else
 let $dist := osm:getDistanceMbr($x,$y,$z,$t,$a,$b,$c,$d)
 return $dist <= $distance 
  
};

(: Si dos mbrs solapan :)
declare function gl:overlap_old($x,$y,$z,$t,$a,$b,$c,$d)
{
   
  if (($x > $c) or ($a > $z)) then false()
                              else if (($t < $b) or ($d < $y)) then
                              false ()
                              else true() 
};

declare function gl:getLayerByName($document,$name,$distance)
{
  for $mbr in $document//mbr[*/tag/@v=$name]
  return 
    gl:getLayer_mbr($document,$mbr,$distance)
};

declare function gl:getLayerByElement($document as node()*,$oneway as node(), $distance)
{

  if ($oneway/way)
  then   
   (:   let $stringName := $oneway/@name
     return :)      
     gl:getLayerByName($document,$oneway/@name,$distance)
   else
     gl:getLayerByName($document,$oneway//tag[@k="name"]/@v,$distance)     
     (:
         let $lat := $oneway/*[1]/@lat, $lon := $oneway/*[1]/@lon
         return
          gl:getLayer_mbr($document,
                   <mbr x = '{$lon}' y = '{$lat}' z = '{$lon}' t = '{$lat}'/>, $distance) 
:)
};

declare function gl:getElementsByKeyword($document as node()*, $string as xs:string)
{
 for $node in ($document//mbr[*/tag/@k=$string]/* union 
               $document//mbr[*/tag/@v=$string]/*)
 return 
  <oneway name =  "{data($node/tag[@k='name']/@v)}"> 
   {$node}
   {let $node2 := for $each in $node/nd return
                               $document/rtree/nodes/node[@id=$each/@ref]     
                               return $node2}
  </oneway> 
}; 

declare function gl:getElementByName($document as node()*, $string as xs:string)
{
<oneway name= "{$string}">  
{$document//mbr[*/tag/@v=$string]/*}
{let $node := for $each in $document//mbr[*/tag/@v=$string]/*/nd return
                               $document/rtree/nodes/node[@id=$each/@ref]    
                               return $node}
</oneway>   
};