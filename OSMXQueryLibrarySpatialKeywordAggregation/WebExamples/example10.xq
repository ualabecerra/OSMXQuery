import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace xosm_ag = "xosm_ag" at "../repo/XOSMAggregationQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexPaseoAlmeria")

let $referenceLayer := rt:getLayerByName($spatialIndex,"Paseo de Almería",0.003),
    $parkAreas := fn:filter($referenceLayer,xosm_kw:searchKeyword(?,"park"))          
return
xosm_ag:metricSum($parkAreas,"area")
