**************************************************************

(: Example 1 :)
(: Find all schools within a 5km radius around a specific location, 
   and for each school find coffeeshops that are closer than 1km :)

(: SPARQL :)

Prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
Prefix ogc: <http://www.opengis.net/ont/geosparql#>
Prefix geom: <http://geovocab.org/geometry#>
Prefix lgdo: <http://linkedgeodata.org/ontology/>

Select ?school ?schoolLabel ?coffeeShop ?coffeeShopLabel
From <http://linkedgeodata.org> {
  ?school
    a lgdo:School ;
    rdfs:label ?schoolLabel ;
    geom:geometry [
      ogc:asWKT ?schoolGeo
    ] .
    
  ?coffeeShop
    a lgdo:CoffeeShop ;
    rdfs:label ?coffeeShopLabel ;
    geom:geometry [
      ogc:asWKT ?coffeeShopGeo
    ] .

  Filter (
    bif:st_intersects (?schoolGeo, bif:st_point (4.892222, 52.373056), 5) &&
    bif:st_intersects (?coffeeShopGeo, ?schoolGeo, 1)
  ) .
}

(: XOSM :)

let $spatialIndex := db:open("spatialIndexArea")
for $schools in fn:filter(rt:getLayerByName($spatialIndex,"specificLocation",0.5),
                xosm_kw:searchKeyword(?,"school"))
return 
 fn:filter(rt:getLayerByElement(.,$schools,0.1),xosm_kw:searchKeyword(?,"coffeeshop"))

**************************************************************

(: Example 2 :)
(: Retrieve all amenities 100 from Leipzig Central Station :)

(: SPARQL :)

Prefix lgdo: <http://linkedgeodata.org/ontology/>
Prefix geom: <http://geovocab.org/geometry#>
Prefix ogc: <http://www.opengis.net/ont/geosparql#>
Prefix owl: <http://www.w3.org/2002/07/owl#>

Select * {
  ?s
    owl:sameAs <http://dbpedia.org/resource/Leipzig_Hauptbahnhof> ;
    geom:geometry [
      ogc:asWKT ?sg
    ] .

  ?x
    a lgdo:Amenity ;
    rdfs:label ?l ;    
    geom:geometry [
      ogc:asWKT ?xg
    ] .


    Filter(bif:st_intersects (?sg, ?xg, 0.1)) .
} Limit 10

(: XOSM :)

let $spatialIndex := db:open("spatialIndexLeipzig_Hauptbahnhof"),
    $layer := rt:getLayerByName($spatialIndex,"Leipzig Central Station",0.001)

return fn:filter($layer,xosm_kw:searchKeyword(?,"amenity"))


**************************************************************

(: Example 3 :)
(: Retrieve all amenities 100m from Connewitz Kreuz :)

(: SPARQL :)

Prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
Prefix ogc: <http://www.opengis.net/ont/geosparql#>
Prefix geom: <http://geovocab.org/geometry#>
Prefix lgdo: <http://linkedgeodata.org/ontology/>

Select *
From <http://linkedgeodata.org> {
  ?s
    a lgdo:Amenity ;
    rdfs:label ?l ;    
    geom:geometry [
      ogc:asWKT ?g
    ] .

    Filter(bif:st_intersects (?g, bif:st_point (12.372966, 51.310228), 0.1)) .
}

(: XOSM :)

let $spatialIndex := db:open("spatialIndexLeipzig"),
    $layer := rt:getLayerByName($spatialIndex,"Connewitz Kreuz",0.001)

return fn:filter($layer,xosm_kw:searchKeyword(?,"amenity"))

**************************************************************

(: Example 4 :)
(: Bakeries in Leipzig :)

(: SPARQL :)
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX ogc: <http://www.opengis.net/ont/geosparql#>
PREFIX geom: <http://geovocab.org/geometry#>
PREFIX lgdo: <http://linkedgeodata.org/ontology/>
PREFIX bif: <http://www.openlinksw.com/schemas/bif#>

SELECT ?s ?sg WHERE {
  ?s
    a lgdo:Bakery ;
    geom:geometry [ ogc:asWKT ?sg ] .

  ?a
    owl:sameAs <http://dbpedia.org/resource/Leipzig> ;
    geom:geometry [ ogc:asWKT ?ag ] .

  Filter(bif:st_intersects(?sg, ?ag))
}
LIMIT 10

(: XOSM :)

let $spatialIndex := db:open("spatialIndexLeipzig")
return rt:getElementsByKeyword($spatialIndex,"bakery")

**************************************************************

(: Example 5 :)
(: Example with a polygon: Bakeries in (roughly) Germany :)

(: SPARQL :)
Prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
Prefix ogc: <http://www.opengis.net/ont/geosparql#>
Prefix geom: <http://geovocab.org/geometry#>
Prefix lgdo: <http://linkedgeodata.org/ontology/>

Select *
From <http://linkedgeodata.org> {
  ?s
    a lgdo:Bakery ;
    rdfs:label ?l ;    
    geom:geometry [
      ogc:asWKT ?g
    ] .

    Filter(bif:st_intersects (?g, bif:st_geomFromText("POLYGON((6.11553983198 54.438016608357, 6.95050076948 47.230985358357, 13.36651639448 47.626493170857, 14.99249295698 54.701688483357, 6.11553983198 54.438016608357))")))
} Limit 10

(: XOSM :)
let $spatialIndex := db:open("spatialIndexGermany"),
    $bakeries := rt:getElementsByKeyword($spatialIndex,"bakery")

return fn:filter($bakeries,function($b)
                {geo:geometry-type(xosm_gml:_osm2GmlElement($b)) = "gml:Polygon"})

**************************************************************