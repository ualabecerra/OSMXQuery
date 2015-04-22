# Querying Open Street Map with XQuery
## Welcome to Project

The aim of this project is to develop a library for querying OSM maps with XQuery. With this aim, we will define a XQuery library that enables to query XML data from OSM. This library is based on the well-known spatial operators defined by Clementini, provinding a ser of XQuery functions that encapsulates the search on the XML document representing a layer of OSM, and makes easy the definition of queries on top of OSM layers. In essence, the library provides a repertory of Urban Operators for points and lines which, in combination with Higher Order facilities of XQuery, makes easy the composition of queries and the definition of keyword based search geo-localized queries. OSM data are indexed by an R-tree structure, in which points and lines are enclosed by Minimum Bounding Rectangles (MBRs), in order to get fast answer time.
 
![Alt text](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Welcome_files/shapeimage_2.png)

TEAM:

<<<<<<< HEAD
* Jesús M. Almendros-Jiménez
* Antonio Becerra-Terón

* Universidad de Almería
* Dpto. Informática
* Crta. Sacramento S/N
* 04120 Almería
=======
* Jesus M. Almendros-Jimenez
* Antonio Becerra-Teron

* Universidad de Almeria
* Dpto. Informatica
* Crta. Sacramento S/N
* 04120 Almeria
>>>>>>> b1566e76afb2ac1518d0c833361db6d2dfcbe7bf

CONTACT:

* [jalmen@ual.es](mailto:jalmen@ual.es)
* [abecerra@ual.es](mailto:abecerra@ual.es)

## Library Download
### rTree Indexing OSM Layers
* [rTree Indexing Library](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Download_files/rtree_library.xq)
* [rTree Indexing Generating Test](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Download_files/rtree_test.xq)

### OSM Layers as BaseX Database
* [OSM XQuery Library](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Download_files/osmXQueryLibrary.xqy)
* [OSM2GML Transformation Library](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Download_files/osm2GmlLibrary.xqy)
* [XQueryTestResults](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Download_files/XQueryTestResultsDef.xq.txt)

### Additional Tools
* [JOSM (Java Open Street Map)](https://josm.openstreetmap.de/)
* [BaseX](http://basex.org/) 

## R-Tree Indexing of OSM Layers
Different figures representing the r-tree index on OSM Maps by using the concept of MBR (Minimum Bounding Rectangles)

![Alt text](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Indexing_files/Media/FigureIndex1/FigureIndex1.jpg)

![Alt text](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Indexing_files/Media/FigureIndex2/FigureIndex2.jpg)
