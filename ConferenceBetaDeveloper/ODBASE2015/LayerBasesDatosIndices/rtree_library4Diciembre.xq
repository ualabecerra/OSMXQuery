module namespace rt = "rtree";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

(: Use mode:  

To generate rtree: rt:load_file(DocumentFileName,RtreeFileName,NumberofChildren)
To generate layer for street: rt:getLayer(RtreeFileName,StreetName)

:)

declare function rt:grow_mbr($x,$y,$z,$t,$a,$b,$c,$d){
  let $minx := min(($x,$a))
  let $maxx := max(($z,$c))
  let $miny := min(($y,$b))
  let $maxy := max(($t,$d))
  return ($minx,$miny,$maxx,$maxy)
};

declare function rt:mbr_size($x,$y,$z,$t){
let $size := (($z - $x) * ($z - $x)) +  (($t - $y) * ($t - $y))
return math:sqrt($size)
};

 

declare function rt:mbr_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rt:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rt:mbr_group_loop(tail($elements),<mbr x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rt:leaf_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rt:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rt:leaf_group_loop(tail($elements),<leaf x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rt:node_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rt:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rt:node_group_loop(tail($elements),<node x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rt:mbr_group($elements){
 let $first := head($elements)
 return
 rt:mbr_group_loop(tail($elements),<mbr x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rt:leaf_group($elements){
 let $first := head($elements)
 return
 rt:leaf_group_loop(tail($elements),<leaf x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rt:node_group($elements){
 let $first := head($elements)
 return
 rt:node_group_loop(tail($elements),<node x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rt:rebuild($leaf,$parents,$siblings,$k)
{
  if (empty($parents)) then $leaf 
                       else 
                       
                       let $brothers := head($siblings)
                       let $children := rt:rebuild($leaf,tail($parents),tail($siblings),$k) 
                       let $numberCh := count($children)
                       return 
                       if ($numberCh>$k) 
                       then
                              let $piece1 := subsequence($children ,1,($k idiv 2)+1)
                              let $piece2 := subsequence($children ,($k idiv 2)+2,$k)
                               
                              
                              
                       
                              return
                              if (name(head($children))="node") then
                                 let $mbr1 := rt:node_group($piece1)
                                 let $mbr2 := rt:node_group($piece2)
                                 
                                 return
                                 
                                 let $result :=
                                 (
                                 <node x="{$mbr1/@x}" y="{$mbr1/@y}" z = "{$mbr1/@z}" t="{$mbr1/@t}">  
                                 {$piece1}
                                 </node>
                                 union 
                                 <node x="{$mbr2/@x}" y="{$mbr2/@y}" z = "{$mbr2/@z}" t="{$mbr2/@t}">  
                                 {$piece2}
                                 </node>
                                 union $brothers/*
                                 )
                                 return $result 
                             else if (name(head($children))="leaf") then
                                 let $mbr1 := rt:leaf_group($piece1)
                                 let $mbr2 := rt:leaf_group($piece2)
                                 
                                 return
                                 let $result :=
                                 (
                                 <node x="{$mbr1/@x}" y="{$mbr1/@y}" z = "{$mbr1/@z}" t="{$mbr1/@t}">  
                                 {$piece1}
                                 </node>
                                 union 
                                 <node x="{$mbr2/@x}" y="{$mbr2/@y}" z = "{$mbr2/@z}" t="{$mbr2/@t}">  
                                 {$piece2}
                                 </node>
                                 union $brothers/*
                                 )
                                 return $result 
                                 
                                 else (: mbr :)
                                 let $mbr1 := rt:mbr_group($piece1)
                                 let $mbr2 := rt:mbr_group($piece2)
                                 
                                 return
                                 let $result :=
                                 (
                                 <leaf x="{$mbr1/@x}" y="{$mbr1/@y}" z = "{$mbr1/@z}" t="{$mbr1/@t}">  
                                 {$piece1}
                                 </leaf>
                                 union 
                                 <leaf x="{$mbr2/@x}" y="{$mbr2/@y}" z = "{$mbr2/@z}" t="{$mbr2/@t}">  
                                 {$piece2}
                                 </leaf>
                                 union $brothers/*
                                 )
                                 return $result 
                                 
                                 
                       else
                      
                        
                       if (name(head($children))="node") then
                       let $newroot := rt:node_group($children)
         
                       return 
                       
                       element node {$newroot/@*, $children} union $brothers/*
                       else 
                       
                       if (name(head($children))="leaf") then
                       let $newroot := rt:leaf_group($children)
                        
                       return 
                       
                       element node {$newroot/@*, $children} union $brothers/*
                       
                       else  (: mbr :)
                       let $newroot := rt:mbr_group($children)
                       return 
                       element leaf {$newroot/@*, $children} union $brothers/*
                        
};

declare function rt:rtree($x, $y, $z, $t, $content, $rtree, $k){
  rt:rtree_loop($x,$y,$z,$t,$content,$rtree,(),(),$k) 
};

declare function rt:rtree_loop($x, $y, $z, $t, $content, $rtree, $parent, $siblings, $k){
  if (empty($rtree)) then  <node x="{$x}" y="{$y}" z = "{$z}" t="{$t}">
                          <leaf  x="{$x}" y="{$y}" z = "{$z}" t="{$t}">
                          <mbr x="{$x}" y="{$y}" z="{$z}" t="{$t}">
                          {$content}
                          </mbr> 
                          </leaf>
                          </node>
                     else
                     if (name(head($rtree))="node") then
                                             let $candidates :=
                                             (for $tree in $rtree
                                             let $mbr := rt:grow_mbr($tree/@x,$tree/@y,$tree/@z,$tree/@t,$x,$y,$z,$t)
                                             let $size := rt:mbr_size($mbr[1],$mbr[2],$mbr[3],$mbr[4]) 
                                             order by $size
                                             return $tree)
                                             let $best:=head ($candidates) 
                                             return
                                              rt:rtree_loop($x,$y,$z,$t,$content,$best/*,
                                              ($parent,<p>{$best}</p>),
                                              ($siblings,<s>{tail($candidates)}</s>),$k)
                                                        
                                             
                                             else (: leaf :)
                       
                                              let $candidates :=
                                              (for $tree in $rtree
                                              let $mbr := rt:grow_mbr($tree/@x,$tree/@y,$tree/@z,$tree/@t,$x,$y,$z,$t)
                                              let $size := rt:mbr_size($mbr[1],$mbr[2],$mbr[3],$mbr[4])
                                              order by $size
                                              return $tree)
                                              let $best:=head ($candidates)
                                              
                                              let $result :=  
                                               
                                              $best/* union
                                              <mbr x="{$x}" y="{$y}" z="{$z}" t="{$t}">
                                              {$content}
                                              </mbr>
                                              
                                               
                                              let $tree := rt:rebuild($result,
                                              ($parent,<p>{$best}</p>),
                                              ($siblings,<s>{tail($candidates)}</s>),$k) 
                                              return
                                              if (count($tree)>1) then
                                              if (name(head($tree))="leaf") then
                                              let $newroot := rt:leaf_group($tree)
                                              return  
                                              <node x="{$newroot/@x}" y="{$newroot/@y}" z = "{$newroot/@z}" 
                                              t="{$newroot/@t}">
                                              {$tree}
                                              </node>
                                              else (: node :)
                                              let $newroot := rt:node_group($tree)
                                              return  
                                              <node x="{$newroot/@x}" y="{$newroot/@y}" z = "{$newroot/@z}" 
                                              t="{$newroot/@t}">
                                              {$tree}
                                              </node>
                                              else $tree
                                                          
};


declare function rt:ways($document)
{
for $value in distinct-values($document//way/tag[@k="name"]/@v)
let $street := $document/osm/way[tag/@v=$value]   
(:let $node := for $each in $street/nd return
$document/osm/node[@id=$each/@ref]:)
let $lat := for $each in $street/nd return
data($document/osm/node[@id=$each/@ref]/@lat)
let $lon := for $each in $street/nd return
data($document/osm/node[@id=$each/@ref]/@lon)
return 
<mbr x="{min($lon)}" y="{min($lat)}" z="{max($lon)}" t="{max($lat)}">
{$street}

</mbr>
(:{$node}:)
};


declare function rt:nodes($document)
{
for $node in $document/osm/node[tag/@k="name"]
return 
<mbr x="{$node/@lon}" y="{$node/@lat}" z="{$node/@lon}" t="{$node/@lat}">
{$node}
</mbr>
};

declare function rt:ways_rtree($ways,$rtree,$k)
{
if (empty($ways)) then $rtree
                  else let $first:=head($ways) 
                       return rt:ways_rtree(tail($ways),
                       rt:rtree($first/@x,$first/@y,$first/@z,$first/@t,
                       $first,$rtree,$k),$k)
};

 

declare function rt:load_file($document,$layer,$k)
{ let $rtree :=
  rt:ways_rtree(rt:ways($document) union rt:nodes($document),(),$k)
  return file:write($layer,<rtree><nodes>{$document//node}</nodes>{$rtree}</rtree>)
};

declare function rt:getLayer_mbr($document,$mbr,$distance)
{
    rt:getLayer_mbr_node($document/rtree/node,$document,$mbr,$distance)
};

declare function rt:getLayer_mbr_node($document,$root,$mbr,$distance)
{
if ($document/node) then  for $node in $document/node 
                              
                                where 
                                rt:overlap(xs:float($node/@x),xs:float($node/@y),xs:float($node/@z),xs:float($node/@t),xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),$distance)
                                 
                                return rt:getLayer_mbr_node($node,$root,$mbr,$distance)
                                else  
                                for $leaf in $document/leaf
                                where rt:overlap(xs:float($leaf/@x),xs:float($leaf/@y),xs:float($leaf/@z),xs:float($leaf/@t),xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),$distance)
                                
                                
                                return for $way in $leaf/mbr 
                                where rt:overlap(xs:float($way/@x),xs:float($way/@y),xs:float($way/@z),xs:float($way/@t),xs:float($mbr/@x),xs:float($mbr/@y),xs:float($mbr/@z),xs:float($mbr/@t),$distance)
                                 
                                return
                                if ($way/mbr/way) then 
                                <oneway name="{($way/mbr/way)[1]/tag[@k="name"]/@v}"> 
                                {let $node := for $each in $way/mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$way/mbr/*} 
                                </oneway> 
                                else 
                                <oneway  name="node"> 
                                {let $node := for $each in $way/mbr/way/nd return
                                $root/rtree/nodes/node[@id=$each/@ref] return $node}
                                {$way/mbr/*}
                                </oneway> 
                  
                                
  
};

declare function rt:overlap($x,$y,$z,$t,$a,$b,$c,$d,$distance)
{
   
 let $dist := osm:getDistanceMbr($x,$y,$z,$t,$a,$b,$c,$d)
 return $dist<=$distance
  
};

declare function rt:overlap_old($x,$y,$z,$t,$a,$b,$c,$d)
{
   
  if (($x > $c) or ($a > $z)) then false()
                              else if (($t < $b) or ($d < $y)) then
                              false ()
                              else true() 
  
};

declare function rt:getLayerByName($document,$name,$distance)
{
  for $mbr in $document//mbr[*/tag/@v=$name]
  return  
   rt:getLayer_mbr($document,$mbr,$distance)
};

declare function rt:getLayerByElement($document,$oneway as node(),$distance)
{
  let $node := $oneway/*[1]
  return 
  if ($node[name(.) = 'way'])
   then   let $stringName := $oneway/@name
          return rt:getLayerByName($document,$stringName,$distance)
  else
         let $lat := $node/@lat, $lon := $node/@lon
         return rt:getLayer_mbr($document, 
         <mbr x = '{$lon}' y = '{$lat}' z = '{$lon}' t = '{$lat}'/>,$distance)
 
};

declare function rt:getElementByName($document as node()*, $string as xs:string)
{
<oneway name= "{$string}">  
{$document//mbr[*/tag/@v=$string]/*}
{let $node := for $each in $document//mbr[*/tag/@v=$string]/*/nd return
                               $document/rtree/nodes/node[@id=$each/@ref]     
                               return $node}
</oneway>   
}; 


 