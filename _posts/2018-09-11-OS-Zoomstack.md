---
layout: post
title:  "Playing with Ordnance Survey's ZoomStack and a new Project"
date:  2018-09-11 
categories: geoserver
---

Over the weekend I was playing around with the [Ordnance Survey's new
Zoomstack](https://www.ordnancesurvey.co.uk/business-and-government/products/os-open-zoomstack.html)
and it is very nice. But I really wanted to see what it looked like in GeoServer
with Charley Glynn's nice [SLDs](https://github.com/OrdnanceSurvey/Ordnance
Survey-Open-Zoomstack-Stylesheets/tree/master/GeoPackage%20and%20PostGIS/Styled%20Layer%20Descriptors%20(SLD)),
but then I would need to take each table in PostGIS and add it to GeoServer and
add the SLD. There are 21 distinct layers (which is much better than the old
days when you needed 100s of layers to cover the whole stack) but was still a
little annoying for what is a simple task I do repeatedly. 

[![](https://imgs.xkcd.com/comics/automation.png)](https://xkcd.com/1319/)

So ignoring XKCD's advice I decided that a tool to automate this was needed. So
I now have a new [project](https://gitlab.com/ijturton/geoserver-loader) based on [GeoTools](http://geotools.org) and [GeoServer
Manager](https://github.com/geosolutions-it/geoserver-manager/wiki). The current
version works nicely for me and my current problem, if your database user isn't
called ian it may work less well for you! 

## Results

For those of you in the UK who haven't played with the Open Zoomstack in
GeoServer yet here are some images.

![](/images/top.png)

![](/images/mid.png)

![](/images/lower.png)

![](/images/bottom.png)
