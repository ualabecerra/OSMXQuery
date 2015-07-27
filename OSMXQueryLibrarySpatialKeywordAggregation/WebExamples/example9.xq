import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexPaseoAlmeria")

let $layerHotels := rt:getElementsByKeyword($spatialIndex,"hotel")
return
xosm_gml:_result2Osm(
  fn:sort($layerHotels,
      function($hotel) 
      {-(count(fn:filter(rt:getLayerByElement($spatialIndex,$hotel ,0.001),
      xosm_kw:searchKeyword(?,("church")))))})[1]
)