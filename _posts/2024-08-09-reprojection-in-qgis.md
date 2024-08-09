---
layout: post
title: How to reproject features in QGIS
date: 2024-08-09
categories: foss
---

I came across a [brilliant thread on 
Mastodon](https://fosstodon.org/@sarahdalgulls@ecoevo.social/112922177589370381) by Sarah Dal discussing how 
she worked out what the most remote post box in the UK was. But there was one remark that bothered me, she 
said that to convert her lat, lon points to OSGB (EPSG:4326 to EPSG:27700 for the nerds) she had to go to the 
Ordnance Survey site to find some software to do this. Since she already had the points in QGIS this seemed 
like an unnecessary side quest to me. When I commented that she could have done this in QGIS she said that she 
always seemed to get it wrong. 

I'm confused by this (and by the many other people who ask questions on gis.stackexchange.com about the same 
thing) so I've put together this video showing how I would do this. Basically, you right click on the layer 
you want to reproject and select `export->Save features as` and then just change the drop down box to the 
projection you need. QGIS will then save the features and add that layer to your project. You shouldn't see 
any difference other than the colour of the points will change (as QGIS assigns a new random colour to the new 
layer). 

<iframe width="420" height="315" src="/images/postboxes-2024-08-09_10.28.30.mp4" frameborder="0" 
allowfullscreen></iframe>

And yes, I really should have split the Northern Irish post boxes out into a separate file and projected them 
to the Irish grid but this is just a demo.
