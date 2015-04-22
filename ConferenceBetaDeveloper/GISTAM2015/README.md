# Querying Open Street Map with XQuery

## Abstract
In this paper we present a library for querying Open Street Map (OSM) with XQuery. This library is based on the well-known spatial operators defined by Clementini and Egenhofer, providing a repertoire of XQuery functions which encapsulate the search
on the XML document representing a layer of OSM, and make the definition of queries on top of OSM layers easy. In essence, the library provides a repertoire of OSM Operators for points and lines which, in combination with Higher Order facilities of XQuery, facilitates the composition of queries and
the definition of keyword based search geo-localized queries. 

The implementation is also based on the transformation of geometric shapes of OSM into the corresponding GML data. 

Then GML data are handled by the Java Topology Suite, available for most of XQuery processors.
OSM data are indexed by an R-tree structure, in which points and lines are enclosed by Minimum Bounding Rectangles (MBRs), in order to get shorter answer time.
 
![Alt text](http://indalog.ual.es/osm/Querying_Open_Street_Map_with_XQuery/Welcome_files/shapeimage_2.png)

### TEAM:

* Jesús M. Almendros-Jiménez
* Antonio Becerra-Terón

* Universidad de Almería
* Dpto. Informática
* Crta. Sacramento S/N
* 04120 Almerí­a

### CONTACT:

* [jalmen@ual.es](mailto:jalmen@ual.es)
* [abecerra@ual.es](mailto:abecerra@ual.es)

## OSM Indexing
In order to handle large city maps, in which the layer can include many objects, an R-tree structure to index objects is used. The R-tree structure is based, as usual, on MBRs to hierarchically organize the content of an OSM map. Moreover, they are also used to enclose the nodes and ways of OSM in leaves of such structure. Figure shows a visual 
representation of the R-tree of a OSM layer for Almería (Spain) city map. These ways have been highlighted in different colors (red and green)
and MBRs are represented by light green rectangles.

The R-tree structure has been implemented as an XML document. That is, the tag based structure of XML is
used for representing the R-tree with two main tags called *node* and *leaf*. A node tag represents the 
MBR enclosing the children nodes, while leaf tag contains the MBR of OSM ways and nodes. The tag *mbr* is used to represent MBRs.

![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/FigureIndexNew.png)

## Examples
* Example 1. Retrieve the schools and high schools close to  *Calzada de Castro* street:

```
fn:filter(
rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:searchTags(?,("high school", "school")))
```

![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/FigureExample1.png)


* Example 2. Retrieve the streets crossing *Calzada de Castro* and
ending to *Avenida Montserrat* street:

```
let $waysCrossing :=  
fn:filter(
rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:isCrossing(?, osm:getOneWay(., "Calle Calzada 
de Castro")))
return 
fn:filter($waysCrossing, osm:isEndingTo(?,
osm:getOneWay(., "Avenida Montserrat")))
```

![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/FigureExample2.png)

* Example 3. Retrieve the schools close to a street, wherein *Calzada de Castro* street ends. 

```
let $waysAllEndingTo :=  
fn:filter(
rt:getLayerByName(.,"Calle Calzada de 
Castro"), osm:isEndingTo(osm:getOneWay(., "Calle
Calzada de Castro"),?))
return 
fn:filter(fn:for-each($waysAllEndingTo,
rt:getLayerByOneWay(.,?)), osm:searchTags(?,"school"))
```
![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/FigureExample3.png)

* Example 4. Retrieve the streets close
to *Calzada de Castro* street, in which there is a supermarket *El Arbol* and a pharmacy (or chemist's).

```
osm:intersectionQuery( 
 osm:unionQuery(
 rt:getLayerByName(.,"El Arbol"), 
 rt:getLayerByName(.,"pharmacy")),
 rt:getLayerByName(.,"Calle Calzada de Castro"))
```
![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/FigureExample4.png)

* Example 5. Retrieve the streets to the north of 
*Calzada de Castro* street:

```
fn:filter(
rt:getLayerByName(.,"Calle Calzada de Castro"), 
osm:furtherNorthWays(
osm:getOneWay(., "Calle Calzada de Castro"),?)) 
```

## Benchmarks
Now we would like to show the benchmarks obtained from the previous examples, for datasets of different sizes.

We have used the *BaseX Query* processor in a Mac Core 2 Duo 2.4 GHz. All benchmarking proofs have been tested using a virtual machine running Windows 7 since the *JTS Topology Suite* is not available for *Mac OS* *BaseX* version. 
Benchmarks are shown in milliseconds in the next Figure.

We have tested Examples 1 to 5 with sizes ranging from two hundred to fourteen thousand objects, corresponding to: from a zoom to *Calzada de Castro* street to the whole Almería city map (around 10 square kilometers). From the benchmarks, we can conclude that increasing the map size, does not increase, in a remarkable way, the answer time.

![Alt text](https://raw.githubusercontent.com/ualabecerra/OSMXQuery/master/ConferenceBetaDeveloper/GISTAM2015/ExampleFigures/benchmarking1.png)


## Conclusions and Future Work
We have presented an XQuery library for querying OSM. We have defined a set of OSM Operators suitable for querying points and streets from OSM. We have shown how higher order facilities of XQuery enable the definition of complex queries over OSM involving composition and keyword searching. We have provided some benchmarks using our library that take 
profit from the R-tree structure used to index OSM. As future work firstly, we would like to extend our library to handle closed ways of OSM, in order to query about buildings, parks, etc. 
Secondly, we would like to enrich the repertoire of OSM operators for points and streets: distance based queries, ranked queries, etc.

Finally, we would like to develop a JOSM plugin, as well as a Web site, with the aim to execute and
to show results of queries directly in OSM maps.
