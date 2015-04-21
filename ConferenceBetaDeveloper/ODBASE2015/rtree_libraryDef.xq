module namespace rtree = "rtree";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy"; 

(: Use mode:  

To generate rtree: rt:load_file(DocumentFileName,RtreeFileName,NumberofChildren)
To generate layer for street: rt:getLayer(RtreeFileName,StreetName)

:)

declare function rtree:grow_mbr($x,$y,$z,$t,$a,$b,$c,$d){
  let $minx := min(($x,$a))
  let $maxx := max(($z,$c))
  let $miny := min(($y,$b))
  let $maxy := max(($t,$d))
  return ($minx,$miny,$maxx,$maxy)
};

declare function rtree:mbr_size($x,$y,$z,$t){
let $size := (($z - $x) * ($z - $x)) +  (($t - $y) * ($t - $y))
return math:sqrt($size)
};

declare function rtree:mbr_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rtree:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rtree:mbr_group_loop(tail($elements),<mbr x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rtree:leaf_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rtree:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rtree:leaf_group_loop(tail($elements),<leaf x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rtree:node_group_loop($elements,$mbr)
{
  if (empty($elements)) then $mbr
                       else let $first:= head($elements)
                            let $mbr2 := rtree:grow_mbr($mbr/@x,$mbr/@y,$mbr/@z,$mbr/@t,$first/@x,$first/@y,$first/@z,$first/@t)
                            return rtree:node_group_loop(tail($elements),<node x="{$mbr2[1]}" y="{$mbr2[2]}" z="{$mbr2[3]}" t="{$mbr2[4]}" />)
};

declare function rtree:mbr_group($elements){
 let $first := head($elements)
 return
 rtree:mbr_group_loop(tail($elements),<mbr x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rtree:leaf_group($elements){
 let $first := head($elements)
 return
 rtree:leaf_group_loop(tail($elements),<leaf x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rtree:node_group($elements){
 let $first := head($elements)
 return
 rtree:node_group_loop(tail($elements),<node x="{$first/@x}" y="{$first/@y}" z="{$first/@z}" t="{$first/@t}"/> )
};

declare function rtree:rebuild($leaf,$parents,$siblings,$k)
{
  if (empty($parents)) then $leaf 
                       else 
                       
                       let $brothers := head($siblings)
                       let $children := rtree:rebuild($leaf,tail($parents),tail($siblings),$k) 
                       let $numberCh := count($children)
                       return 
                       if ($numberCh>$k) 
                       then
                              let $piece1 := subsequence($children ,1,($k idiv 2)+1)
                              let $piece2 := subsequence($children ,($k idiv 2)+2,$k)
                              
                              return
                              if (name(head($children))="node") then
                                 let $mbr1 := rtree:node_group($piece1)
                                 let $mbr2 := rtree:node_group($piece2)
                                 
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
                                 let $mbr1 := rtree:leaf_group($piece1)
                                 let $mbr2 := rtree:leaf_group($piece2)
                                 
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
                                 let $mbr1 := rtree:mbr_group($piece1)
                                 let $mbr2 := rtree:mbr_group($piece2)
                                 
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
                       let $newroot := rtree:node_group($children)
         
                       return 
                       
                       element node {$newroot/@*, $children} union $brothers/*
                       else 
                       
                       if (name(head($children))="leaf") then
                       let $newroot := rtree:leaf_group($children)
                        
                       return 
                       
                       element node {$newroot/@*, $children} union $brothers/*
                       
                       else  (: mbr :)
                       let $newroot := rtree:mbr_group($children)
                       return 
                       element leaf {$newroot/@*, $children} union $brothers/*
};

declare function rtree:rtree($x, $y, $z, $t, $content, $rtree, $k){
  rtree:rtree_loop($x,$y,$z,$t,$content,$rtree,(),(),$k) 
};

declare function rtree:rtree_loop($x, $y, $z, $t, $content, $rtree, $parent, $siblings, $k){
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
                                             let $mbr := rtree:grow_mbr($tree/@x,$tree/@y,$tree/@z,$tree/@t,$x,$y,$z,$t)
                                             let $size := rtree:mbr_size($mbr[1],$mbr[2],$mbr[3],$mbr[4]) 
                                             order by $size
                                             return $tree)
                                             let $best:=head ($candidates) 
                                             return
                                              rtree:rtree_loop($x,$y,$z,$t,$content,$best/*,
                                              ($parent,<p>{$best}</p>),
                                              ($siblings,<s>{tail($candidates)}</s>),$k)
                                                   
                                             else (: leaf :)
                       
                                              let $candidates :=
                                              (for $tree in $rtree
                                              let $mbr := rtree:grow_mbr($tree/@x,$tree/@y,$tree/@z,$tree/@t,$x,$y,$z,$t)
                                              let $size := rtree:mbr_size($mbr[1],$mbr[2],$mbr[3],$mbr[4])
                                              order by $size
                                              return $tree)
                                              let $best:=head ($candidates)
                                              
                                              let $result :=  
                                               
                                              $best/* union
                                              <mbr x="{$x}" y="{$y}" z="{$z}" t="{$t}">
                                              {$content}
                                              </mbr>
                                              
                                               
                                              let $tree := rtree:rebuild($result,
                                              ($parent,<p>{$best}</p>),
                                              ($siblings,<s>{tail($candidates)}</s>),$k) 
                                              return
                                              if (count($tree)>1) then
                                              if (name(head($tree))="leaf") then
                                              let $newroot := rtree:leaf_group($tree)
                                              return  
                                              <node x="{$newroot/@x}" y="{$newroot/@y}" z = "{$newroot/@z}" 
                                              t="{$newroot/@t}">
                                              {$tree}
                                              </node>
                                              else (: node :)
                                              let $newroot := rtree:node_group($tree)
                                              return  
                                              <node x="{$newroot/@x}" y="{$newroot/@y}" z = "{$newroot/@z}" 
                                              t="{$newroot/@t}">
                                              {$tree}
                                              </node>
                                              else $tree
};

declare function rtree:ways($document)
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

declare function rtree:nodes($document)
{
for $node in $document/osm/node[tag/@k="name"]
return 
<mbr x="{$node/@lon}" y="{$node/@lat}" z="{$node/@lon}" t="{$node/@lat}">
{$node}
</mbr>
};

declare function rtree:ways_rtree($ways,$rtree,$k)
{
if (empty($ways)) then $rtree
                  else let $first:=head($ways) 
                       return rtree:ways_rtree(tail($ways),
                       rtree:rtree($first/@x,$first/@y,$first/@z,$first/@t,
                       $first,$rtree,$k),$k)
};

declare function rtree:load_file($document,$layer,$k)
{ let $rtree :=
  rtree:ways_rtree(rtree:ways($document) union rtree:nodes($document),(),$k)
  return file:write($layer,<rtree><nodes>{$document//node}</nodes>{$rtree}</rtree>)
};