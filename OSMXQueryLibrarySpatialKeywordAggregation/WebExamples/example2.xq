import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_sp = "xosm_sp" at "../repo/XOSMSpatialQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexCalzadaCastroAlmeria")

let $referenceWay1 := rt:getElementByName($spatialIndex, "Calle Calzada de Castro"),
    $referenceWay2 := rt:getElementByName($spatialIndex, "Avenida Nuestra Señora de Montserrat"),
    $referenceLayer := rt:getLayerByName($spatialIndex,"Calle Calzada de Castro",0),
    $onewaysCrossing := fn:filter($referenceLayer, 
                        xosm_sp:isCrossing(?, $referenceWay1))
return
xosm_gml:_result2Osm(
  fn:filter($onewaysCrossing,xosm_sp:isEndingTo(?,$referenceWay2)) 
)