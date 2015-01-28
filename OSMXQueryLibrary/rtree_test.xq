import module namespace rt = "rtree" at "rtree_library2.xq";

(: rt:load_file(.,"C:/Users/Administrator/Desktop/HitoDiciembre2014/rtree_300metersCalzadaCastro.osm",20) :)
 
(:  rt:load_file(.,"C:/Users/Administrator/Desktop/HitoNoviembre2014/rtree_30meters.osm",4) :)
 

rt:getLayerByName(.,"ACUYO IRIARTE",0.001)


