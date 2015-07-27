import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace xosm_ag = "xosm_ag" at "../repo/XOSMAggregationQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexPaseoAlmeria")

let $hotels := fn:filter(rt:getLayerByName($spatialIndex,"Paseo de Almería",0.003), 
               xosm_kw:searchKeyword(?,"hotel"))                  
return
xosm_gml:_result2Osm( 
   xosm_ag:metricMode($hotels,"stars")
)
