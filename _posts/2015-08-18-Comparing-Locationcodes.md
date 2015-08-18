---
layout: post
title: Comparing Location Codes Around the World
categories: location rest mapping
---

The
[debate](http://fulcrumapp.com/blog/comparing-address-and-coordinate-systems/)
about location codes continues with Google entering the market place with it's
[Open Location Codes](http://openlocationcode.com/) and
[MapCode](http://www.mapcode.com/) from a Dutch team of former TomTom
employees. There is also [ubicate.me](http://ubicate.me) (which claims to be open source but doesn't
seem to have any code).

What seems to be missing is an easy way to compare the codes that reference a location, so following on from my [last blog post](/geotools/w3w/2015/08/06/What-3-Words-fun.html) I've put together a [REST service](http://locations.ianturton.com/LocationsWebService/locations/locationservice/50.81222621505467,-0.3716468811035156) that takes a latitude longitude pair and returns a set of location codes. 

I have also provided a [demonstration page](http://locations.ianturton.com/LocationsWebService/) to allow you to move around and see how the different schemes compare.

I implemented the Google Open Location Code in Java based on the released java script code I've submitted a [pull request](https://github.com/google/open-location-code/pull/21) or you can fork [my repo](https://github.com/ianturton/open-location-code).

MapCode provide a Java library - you just need add the following to your pom file:
        
    <dependency> 
       <groupId>com.mapcode</groupId> 
       <artifactId>mapcode</artifactId>
       <version>2.0.0</version>
    </dependency>
                                                
                                                    
                                                        
MGRS is based on code from this [repository](https://github.com/Berico-Technologies/Geo-Coordinate-Conversion-Java) which builds on the NASA WorldWind base.

The What3Words code is actually quite easy and is available [here](https://gist.github.com/ianturton/9d01198752b82520f602). The only tricky bit is keeping your API key out of the repository.
