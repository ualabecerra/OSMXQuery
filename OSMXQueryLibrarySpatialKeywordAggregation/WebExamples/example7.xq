import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexCalzadaCastroAlmeria")

let $referenceOneways := rt:getElementsByKeyword($spatialIndex,"pharmacy")
return
xosm_gml:_result2Osm(
  fn:for-each($referenceOneways,rt:getLayerByElement($spatialIndex, ?, 0.001))
)