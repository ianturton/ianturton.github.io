---
layout: post
title:  "Building Strip Maps with QGis 3.4"
date:  2019-02-23
categories: qgis
---

Strip Maps
----------

On a recent QGis course I was asked if it was possible to make "strip maps"? As
a longish digression as to what one of those was, we started to experiment with
it. According to
[ESRI](https://desktop.arcgis.com/en/arcmap/10.3/map/page-layouts/preparing-the-strip-map.htm) they are: 

>A strip map is a set of map pages that follow a route, such as a river, road, or pipeline. Each page of the map shows a defined geographic area on either side of the line feature. Each subsequent page in a strip map shows the area further down the line. Often, there is a bit of geographic overlap between adjacent map pages. The direction of north on the page shifts so that the flow of map is kept constant.

They were also popular a long time ago.

![tweet](/images/tweet.png)

There is a
[question](https://gis.stackexchange.com/questions/173127/generating-equal-sized-polygons-along-line-with-pyqgis)
on [gis.stackexchange.com](https://gis.stackexchange.com/) but that is
for QGIS 2.x and being a modern (or foolish) type I'm using 3.x on all
of my computers now.  So could we build them using QGIS? First we'd need
to split the route up into pieces of the correct length. However, one of the
answers does point to the `v.split` process in the Grass section. 


