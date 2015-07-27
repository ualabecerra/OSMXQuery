import module namespace xosm_gml = "xosm_gml" at "../repo/XOSM2GmlQueryLibrary.xqy";

import module namespace xosm_kw = "xosm_kw" at "../repo/XOSMKeywordQueryLibrary.xqy";

import module namespace rt = "rtree" at "../repo/rtree_library.xq";

let $spatialIndex := db:open("spatialIndexPaseoAlmeria")

let $layerHotels := rt:getElementsByKeyword($spatialIndex,"hotel")
return
xosm_gml:_result2Osm(
 fn:filter(fn:for-each($layerHotels,
  function($hotel)
  {<hotelLayer>
     {rt:getLayerByElement($spatialIndex,$hotel,0.002)}
  </hotelLayer>}),
     function($hotelLayer)
     {count(fn:filter($hotelLayer/*, 
     xosm_kw:searchKeywordSet(?,("bar","restaurant","cafe")))) >= 3})
)