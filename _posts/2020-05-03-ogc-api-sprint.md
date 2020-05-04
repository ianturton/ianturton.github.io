---
layout: post
title: GeoTools and the OGC APIs
date: 2020-05-03
categories: ogc geotools 
---

The OGC and Ordnance Survey held a [code sprint](https://www.ogc.org/ogcevents/ogc-api-tiles-code-sprint-virtual-event)
at the end of April, it was of course virtual. I was
pleased to participate representing both [Astun](http://astuntechnology.com) 
and the [GeoTools](http://geotools.org)/ [GeoServer](http://geoserver.org) communities. The main aim of the
sprint was to experiment and validate the new draft [OGC API - Tiles](https://github.com/opengeospatial/OGC-API-Tiles) 
specification.

I had originally
thought I could help Andrea Aime out in the implementation of the tiles specification in GeoServer, but that
turned out to be pretty much finished, so I thought may be I could help out with testing the [GeoServer
implementation](https://docs.geoserver.org/latest/en/user/community/ogc-api/index.html). However, it seemed
there was a shortage of portable clients. There were lots of teams there with a client that ran on their
machine that could pull in features from a remote server, or large projects such as [MapStore](https://mapstore.geo-solutions.it/mapstore/#/)
, but in those cases the amount of set up was too much for the simple tests I wanted to run. In the end we
probably want to build automated tests and such like. Ultimately, this could also be used to allow GeoServer
to cascade the new OGC APIs to older clients that hadn't taken them up yet.

Therefore I decided to start building a simple client in GeoTools based, in part, on the existing WMTS tile
client. The first version of this very preliminary of this client code is now merged into the [GeoTools master
branch](https://github.com/geotools/geotools/pull/2905). If you need this functionality or just want to have a
quick play with a simple client for the OGC APIs feel free to have a play with it. Even better would be PRs
that speed it up or fix the UI issues where I do horrible things to the Swing threads! Overtime, I plan to add
support for the tiles API as well, which should speed things up a lot.

![tile viewer](/images/tileviewer.png)


## Feedback on the API specifications

In general the API specification for Features is quite nice to work with, though there is a lot of duplication
at some levels. For example, to get the details of a "layer" I need to work through several endpoints to get
to key information (like the styles, the names of which I will need if I ever implement tiled maps).
