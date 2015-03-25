import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

import module namespace geo = "http://expath.org/ns/geo";

import module namespace osm_gml = "osm_gml" at "osm2GmlLibrary.xqy";

declare namespace gml='http://www.opengis.net/gml';

import module namespace rt = "rtree" at "rtree_libraryDef.xq";

import module namespace gl = "getLayer" at "getLayerLibrary.xqy";

import module namespace tk = "topK" at "topKLibrary.xqy";

**************************************************************

(: Query 1 :)
(: Dame las cinco calles más cercanas a Méndez Nuñez :)

(: Versión topK_library :)

osm_gml:_result2Osm( 
      tk:closestTopKByName(.,"Paseo de Almería",5)/*
    )

(: Versión getLayer_library :)

let $candidates := <candidates>
{
for $oneway in gl:getLayerByName(., "Paseo de Almería", 1) 
order by $oneway/@distance
return $oneway
}
</candidates>

return 
    osm_gml:_result2Osm(
        (<candidates mindist = "{$candidates/*[1]/@distance}" maxdist = "{$candidates/*[5]/@distance}" 
         objects = "5">{fn:subsequence($candidates/*,1,5)}
    </candidates>)/*
  )
    
(: Query 2 :)
(: Dame los cinco restaurantes más cercanos al Teatro Cervantes / Calle Padre Santaella :)

(: Versión topK_library :)

 osm_gml:_result2Osm(
   tk:closestTopKWrtNameByKeywords(.,"Teatro Cervantes","restaurant",5)/*
 )
 
(: Versión getLayer_library :)

let $candidates := <candidates>
{
for $oneway in gl:getLayerByName(., "Teatro Cervantes", 1) 
order by $oneway/@distance
where osm:searchTags($oneway,"restaurant")
return $oneway
}
</candidates>

return 
    osm_gml:_result2Osm(
     (<candidates mindist = "{$candidates/*[1]/@distance}" maxdist = "{$candidates/*[5]/@distance}" 
    objects = "5">{fn:subsequence($candidates/*,1,5)}
     </candidates>)/*
    )

(: Query 3 :)
(: Dame el restaurante mas cercano de los k hoteles más próximos al Paseo de Almería :)

(: Versión topK_library :)

osm_gml:_result2Osm(
       for-each(tk:closestTopKWrtNameByKeywords(.,"Paseo de Almería","hotel",5)/*, tk:closestTopKWrtElementByKeywords(.,?,"restaurant",1)
     )/*
    )  
    
(: Versión getLayer_library :) 

let $candidates := <candidates>
{
for $oneway in gl:getLayerByName(., "Paseo de Almería", 1) 
order by $oneway/@distance
where osm:searchTags($oneway,"hotel")
return $oneway
}
</candidates>

return 
 osm_gml:_result2Osm(
   fn:filter(
         for-each(fn:subsequence($candidates/*,1,5),
         gl:getLayerByElement(.,?,0.1)),
         osm:searchTags(?,"bar")
       ) 
  )

(: Query 4 :)
(: Dame todos los restaurantes que están a menos de 300 metros del Hotel Costasol :)

(: Versión topK_library :)

osm_gml:_result2Osm(tk:closestDistanceWrtNameByKeywords(.,"Hotel Costasol", "restaurant", 0.003)/*)
 
(: Versión getLayer_library :) 

let $candidates := <candidates>
{
for $oneway in gl:getLayerByName(., "Hotel Costasol", 1) 
order by $oneway/@distance
where osm:searchTags($oneway,"restaurant") and $oneway/@distance < 0.003
return $oneway
}
</candidates>

return 
    osm_gml:_result2Osm(
      (<candidates mindist = "{$candidates/*[1]/@distance}" 
    maxdist = "{$candidates/*[count($candidates/*)]/@distance}" 
    objects = "{count($candidates/*)}">{$candidates/*}
    </candidates>)/*
  )
       
(: Query 5 :)
(: Dame los restaurantes que están a menos de 300 metros de todos los hoteles de la capa :)

(: Versión topK_library :)

osm_gml:_result2Osm(
  for-each(
        gl:getElementsByKeyword(.,"hotel"),
  tk:closestDistanceWrtElementByKeywords(.,?,"restaurant", 0.003)
     )/*       
  )

(: Versión getLayer_library :)

let $candidates := <candidates>
{
for $oneway1 in gl:getElementsByKeyword(.,"hotel")
for $oneway2 in gl:getLayerByElement(., $oneway1, 1) 
order by $oneway2/@distance
where osm:searchTags($oneway2,"restaurant")and $oneway2/@distance < 0.003
return $oneway2
}
</candidates>

return 
    osm_gml:_result2Osm(
      (<candidates mindist = "{$candidates/*[1]/@distance}" 
    maxdist = "{$candidates/*[count($candidates/*)]/@distance}" 
    objects = "{count($candidates/*)}">{$candidates/*}
    </candidates>)/*
  )

(: Query 6 :)
(: Dame el hotel que está a menos de 300 metros del Teatro Cervantes y  
   más cerca de la Parroquia San Pedro :)

(: Versión topK_library :)

 osm_gml:_result2Osm(
    tk:closestElementByCollection(gl:getElementByName(.,"Parroquia San Pedro"),
       tk:closestDistanceWrtNameByKeywords(.,"Teatro Cervantes","hotel",0.003))
   ) 

(: Versión getLayer_library :)

let $candidates := <candidates>
{
for $oneway in gl:getLayerByName(., "Teatro Cervantes", 1) 
order by $oneway/@distance
where osm:searchTags($oneway,"hotel") and $oneway/@distance < 0.003
return $oneway
}
</candidates>

return 
    let $collection := 
      (<candidates mindist = "{$candidates/*[1]/@distance}" 
    maxdist = "{$candidates/*[count($candidates/*)]/@distance}" 
    objects = "{count($candidates/*)}">{$candidates/*}
    </candidates>)
   return 
 osm_gml:_result2Osm(tk:closestElementByCollection(gl:getElementByName(.,"Parroquia San Pedro"),$collection)
 )
