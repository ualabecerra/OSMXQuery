import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexCalzadaCastroAlmeria")

let $referenceLayer := rt:getLayerByName($spatialIndex,"Calle Calzada de Castro",0.001)
return 
xosm_gml:_result2Osm(
  fn:filter($referenceLayer,
           xosm_kw:searchKeywordSet(?,("high school","school")))
)