---
layout: post
title:  "Finding the projection of an unknown set of coordinates"
categories: geotools, projections
---

One of the recurring questions on GIS stackexchange is "I have these points
with an unknown projection, can you help?" (at last count more than 100). The
answer always depends on if the hapless user knows roughly where they should
be. Hint: if you don't know where your data should be or it's projection then
you have a list of numbers not a spatial data set! The next suggestion is to ask
the person or organisation that supplied it (sadly this rarely seems to help).

So to help out with this (apparently) common issue I wrote some GeoTools based
code to attempt to find a matching projection. 

First it looks up a location using the [GeoNames
API](http://www.geonames.org/export/web-services.html) to get a target point in
WGS84. Then we can hunt through the CRS list and pick any which are in the area
of validity. Finally we can try transforming the WGS84 point using
these possible projections and keep the one which is closest to our unknown
point. One small wrinkle is the need to convert the distance to metres
(otherwise the ones in feet are always 3 times further away than expected).

The full code is available for you to experiment with
[here](https://gitlab.com/snippets/34902) and a
[pom.xml](https://gitlab.com/snippets/35169) to build it with.


