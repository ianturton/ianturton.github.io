---
layout: post
title: Adventures with Topology in GeoTools
date: 2021-08-23
categories: geotools
---

# Adventures with Topology in GeoTools

A [question](https://gis.stackexchange.com/q/407860/79) was asked on GIS Stackexchange the other day, which caught my eye. I find that user questions are an excellent way of discovering gaps in the GeoTools documentation or as in this case a gap in the functionality of the library. The questioner wanted to simplify a polygon layer and not end up with slivers between their polygons. They had searched and found the JTS `TopologyPreservingSimplifier` which sounds like it does exactly what they want. Sadly, it doesn't the *topology* referred to here is of the *geometry* not the layer. That is, if you pass a polygon in it will return you a polygon not a line (other simplifiers don't necessarily do that). 

Another user suggested that [OpenJUMP](http://www.openjump.org/) had a tool for simplifying polygon layers and as OpenJUMP is built on top of JTS too I thought it would be worth looking to see if I could port the code to GeoTools. Unfortunately, OpenJUMP is significantly different to GeoTools so a simple port looked like a lot of work. But it turns out the principal is quite easy to understand. There are 4 steps to the algorithm:

1. Find the neighbours of each polygon
2. Break each polygon down into a set of lines, keeping a note of their neighbouring polygons.
3. Simplify the lines (including the ones that are not shared)
4. Stitch the polygons back together from the simplified lines and update the features.

Step 1 is just a case of looping through the features and finding all the polygons that the geometry intersects (ignoring itself). Then (step 2) you find the intersection of each neighbour with the feature geometry and store that in a `Set` with the neighbour's id. You also need to build a "shared" geometry so that you can store the remaining "unshared" geometry too. 
Step 3 is easy as JTS provides several simplifiers that can be used, I went with the `TopologyPreservingSimplifier` since its possible for a polygon to be passed in whole (e.g. an island). 
Finally, for step 4 its a simple case of passing all the simplified lines into the JTS `Polygonizer` and asking it to build a polygon for us.

If you are interested in playing with the code its available [here](https://gitlab.com/-/snippets/2161619). Eventually, I would like to add this code into GeoTools as a process but the code needs cleaning up, it doesn't currently handle holes in polygons and the error handling needs work. To be really useful GeoTools really needs something like the QGIS topology checker and a way to fix those issues since if the input polygon layer is not topologically perfect you will still get slivers forming where the two polygons don't match exactly. 
