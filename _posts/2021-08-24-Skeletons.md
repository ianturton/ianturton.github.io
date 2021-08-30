---
layout: post
title: Skeletization of Polygons
date: 2021-08-23
categories: geotools
---

# Topological Skeletonization of Polygons 

Unlike my other [recent forays](/geotools/2021/08/23/Topological-Adventures.html) into topology this is self guided (or all my own fault). I was looking for a way to put a "centre-line" into a polygon to use as a label line, I think I first saw this suggested in [QGIS Map Design](https://locatepress.com/qmd2) and I remember thinking it was a cool idea but that book is very much retail map design while I'm more of a wholesale guy (that is I want to make 100s of maps a minute rather than spend all day over one map (most of the time)). So I was wondering if I could write a function that would automatically provide a centre line of a polygon (possibly with holes) to feed into an SLD file to place my labels on automatically. 

After some thinking (and googling) I came up with the idea of using the [skeleton of the polygon](https://en.wikipedia.org/wiki/Topological_skeleton) there are many algorithms that can be used to produce this result, in the end I went for ["An Optimized Algorithm for Computing the Voronoi Skeleton" by Dmytro Kotsur, Vasyl Tereshchenko](https://www.computingonline.net/files/journals/1/archieve/IJC_2020_19_4_03.pdf) partly because I knew what a Voronoi network was and partly because it is actually available for me to read. 


The paper takes a little understanding but basically takes 13 pages to say create the Voronoi triangulation and then throw away any of the triangles that touch the original polygon. There's a bit on how to optimise the algorithm (i.e. simplify the polygon first). 
As I have done previously, I cribbed some ideas from [OpenJUMP's Skeleton Plugin](https://github.com/openjump-gis/graph-toolbox-extension/blob/main/src/main/java/fr/michaelm/jump/plugin/graph/SkeletonPlugIn.java) to get me started. I'm not sure who wrote this code but I suspect they lived a lot closer to Martin Davis' office than I do and they seem to know what they are doing. 
Now JTS provides an excellent (i.e. I don't understand it) Voronoi triangulator (`VoronoiDiagramBuilder`) which does all the hard work. You can set the bounds (the envelope of the polygon) and then feed it the points of the polygon.

![Voronoi Diagram of Ullswater](/images/voronoi.png "Voronoi Diagram of Ullswater")

If instead of keeping each edge in the diagram we keep only those that are contained in the polygon we get the skeleton of the polygon.

![Skeleton of Ullswater](/images/centreline.png "Skeleton of Ullswater")


When we wrap this up inside a `Process` we can use it in our SLD to provide a centre line to label on.

```xml
      <TextSymbolizer>
        <Geometry>
          <ogc:Function name="CentreLine:centreLine">
            <ogc:Function name="parameter">
              <ogc:Literal>geometry</ogc:Literal>
              <ogc:PropertyName>the_geom</ogc:PropertyName>
            </ogc:Function>
          </ogc:Function>
        </Geometry>
        <Label><ogc:PropertyName>NAME</ogc:PropertyName></Label>
        <LabelPlacement>
          <LinePlacement/>
        </LabelPlacement>
        <Halo/>
        <VendorOption name="followLine">true</VendorOption>
        <VendorOption name="maxDisplacement">10</VendorOption>
      </TextSymbolizer>
```

It sort of works (as you can see below):

![Ennerdale Water](/images/ennerdale.png "Ennerdale Water")

But for more complex lakes (like Wast Water) you have to zoom in a long way to get a label to display:

![Wast Water](/images/wastwater.png "Wast Water")

In an ideal world I would then trim of the dangling lines and only keep the long central line, but I haven't worked out a good way to do that yet - can you help?
