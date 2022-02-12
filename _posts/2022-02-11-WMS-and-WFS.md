---
layout: post
title: Converting a WMS URL to a WFS Request
date: 2022-02-11
categories: ogc
---

# How to change a WMS URL to a WFS URL

This week I saw a new mappy meme:


![Make the actual data available for analysis? Best I can do is a WMS](/images/meme.png )

and I had a quiet snigger and then made a throw away tweet, that it is usually pretty easy to back engineer 
the related WFS URL from the WMS one. To be honest, I thought everyone did this as a standard part of their 
data analysis day to day toolkit. But from the responses I saw apparently not everyone knows how to do this. 
So, I thought I would write a post explaining some of the basics of how WMS and WFS URLs work.

## First, find some data

For an example, I went to `data.gov.uk` and filtered for WMS. After a couple of false starts, I picked [Fish 
Landings to United Kingdom Ports 2014 Web Mapping Service 
(WMS)](https://data.gov.uk/dataset/2b46ca8d-49af-403c-9b3d-562731e867a9/fish-landings-to-united-kingdom-ports-2014-web-mapping-service-wms) 
which contains:

> Annual statistics for commercial fishing activity by UK registered fishing vessels for the year indicated.

Which to be honest sounds like it should be a CSV file (but that is a rant for another day). The Marine 
Management Organisation provide a [WMS 
link](http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--e9f68cafd7e937c07e697439493ff06d&request=GetCapabilities) 
which we can also [preview on their 
map](https://data.gov.uk/data/map-preview?e=57.3000&n=69.6582&s=-29.8697&url=http%3A%2F%2Fenvironment.data.gov.uk%2Fds%2Fwms%3FSERVICE%3DWMS%26INTERFACE%3DENVIRONMENT--e9f68cafd7e937c07e697439493ff06d%26request%3DGetCapabilities&w=-15.4217). 

![A web map viewer showing the fishing port landing amounts](/images/data.gov.uk.png)

But we want the data not a picture of the data (especially not that picture)!

## How WMS works (a side trip)

Before we can start deconstructing URLs we need some background knowledge about how WMS and WFS work. You may 
have seen WMS used in web browsers or QGIS where you get asked for a capabilities URL or a base URL. This is 
some times what you find on data sites, unfortunately there is a subtle difference between the two and 
experienced professionals have met them so often that we forget to mention them most of the time. If we 
examine the URL on the `data.gov.uk` page we will see:

    http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--e9f68cafd7e937c07e697439493ff06d&request=GetCapabilities

Which is a capabilities URL, that is it will return a `GetCapabilities` document (an XML file) which a smart 
client can use to work out which layers, styles and projections are supported by this server. A base URL is 
the part to the left of the `?` which is the machine name and the path to the server end point, when people 
give you this it means they expect you (or your client) to be smart enough to build a `GetCapabilities` 
request URL from this information and your knowledge of the [WMS 
specification](portal.opengeospatial.org/files/?artifact_id=14416). 

I'll run down the required parameters for those of you going TL;DR on that 85 page PDF. 

The WMS standard requires that a WMS server provides a way of asking for the capabilities of the server and 
since you currently have no idea of what the server can or can't do yet it needs to be easy. There are two 
required parameters:

1. **`REQUEST`** - this tells the server what you would like it to do, there are many options for what can go 
   in here but all OGC services (before version 3) must support `GetCapabilities` as an option, and they 
   return a well structured XML file to the client making the request. 
2. **`SERVICE`** - this tells a server with multiple end points which of it's services you would like to talk 
   to, again there are many possibilities but in our case it will be `WMS`.

There is an optional **`VERSION`** parameter that you can send if there is a highest version you can handle, 
otherwise the server will respond with the highest it can support. 

Any other parameters are (usually) ignored by the server but may be required by the service for authentication 
or reporting, so we can just ignore the `INTERFACE` parameter as it doesn't affect us, though if you leave it 
out the service stops working so it must do something.

## Getting to the WFS 

Above, I explained that the WMS standard requires the provision of the `GetCapabilities` end point, in fact 
all OGC services have to support this, so to check if the Marine Management Organisation happens to be running 
a more useful WFS service as well as their WMS (even though they don't mention it in the metadata). There is a 
pretty good chance that they are as both GeoServer and MapServer provide both and there is extra work in 
turning it off (not much but some). 

As you would expect a `GetCapabilities` request to a WFS server looks almost exactly like a WMS request but 
with WMS changed to WFS in the `SERVICE` parameter. Often you will need to change any `wms` in the URL to 
`wfs` too. So if we take the WMS request and make those changes and get:

    https://environment.data.gov.uk/ds/wfs?SERVICE=WFS&INTERFACE=ENVIRONMENT--e9f68cafd7e937c07e697439493ff06d&request=GetCapabilities

Again, I've left the `INTERFACE` parameter in. Trying this URL in your browser or at the CLI with `curl` we 
get back another [XML 
file](https://environment.data.gov.uk/ds/wfs?SERVICE=WFS&INTERFACE=ENVIRONMENT--e9f68cafd7e937c07e697439493ff06d&request=GetCapabilities). 
Scrolling through this we can see details of all the layers that we could want. So I can not use `ogr2ogr` to 
extract a CSV file of the amount of fish landed in each point:

    ogr2ogr -f CSV fish.csv  \
    WFS:"https://environment.data.gov.uk/ds/wfs?SERVICE=WFS&INTERFACE=ENVIRONMENT--e9f68cafd7e937c07e697439493ff06d&request=GetCapabilities"  \
    UK_Port_Fishing_Effort_2014_all_vessels

which gives me:

~~~
gml_id,OBJECTID,year,length_gp,port,port_code,lat,long,totkwdays,mobkwdays,passkwdays,totqty,mobqty,passqty,totval,mobval,passval
UK_Port_Fishing_Effort_2014_all_vessels.1,"1",2014,All Vessels,Aalborg,5002,57.050017,10.052811,884,884,0,2.6516,2.6516,0,2382.64,2382 .64,0
UK_Port_Fishing_Effort_2014_all_vessels.2,"2",2014,All Vessels,Abbotsbury,678,50.67,-2.6,0,0,0,2.317,0,2.317,8404.33,0,8404.33
UK_Port_Fishing_Effort_2014_all_vessels.3,"3",2014,All Vessels,Aberdaran,872,52.8,-4.71667,18041.28,0,18041.28,31.2214,0,31.2214,15309 8.1,0,153098.1
UK_Port_Fishing_Effort_2014_all_vessels.4,"4",2014,All Vessels,Aberdeen,1407,57.1425,-2.07778,139710.92,121704.92,18006,460.681,381.83 71,78.8439,881518.98,736982.33,144536.65
...
~~~

And I'm all set to do some analysis, of course I could also just have connected to that endpoint in QGIS if I 
needed to do a spatial analysis.


Now I'm not going to claim that this will work for all WMS services out there but I've found it well worth 
trying when all they are offering is a WMS endpoint.
