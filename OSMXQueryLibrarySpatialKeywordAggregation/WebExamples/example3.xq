import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_sp = "xosm_sp" at "../repo/XOSMSpatialQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexCalzadaCastroAlmeria")

let $referenceWay := rt:getElementByName($spatialIndex, "Calle Calzada de Castro"),
    $referenceLayer := rt:getLayerByName($spatialIndex,"Calle Calzada de Castro", 0),
    $onewaysAllEndingTo := fn:filter($referenceLayer, 
                           xosm_sp:isEndingTo($referenceWay,?))
return
xosm_gml:_result2Osm(
    fn:filter(fn:for-each($onewaysAllEndingTo, rt:getLayerByElement($spatialIndex,?,0.001)), 
            xosm_kw:searchKeyword(?,"school"))
)