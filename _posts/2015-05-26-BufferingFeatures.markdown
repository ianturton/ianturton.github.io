---
layout: post
title: Buffering a GPS Track (or other feature) in GeoTools
categories: geotools features reprojection buffering
---

Following a
[question](http://stackoverflow.com/questions/30426901/generate-a-polygon-from-a-linegps-coordinate-in-a-defined-distancekm-with-ge)
on StackOverflow.com I got to thinking about Buffering. In the general sense
this is an easy operation to use in GeoTools as JTS (the underlying spatial
library we use) provides a .buffer method on Geometry objects. All you have to
do is pass in a distance in the map units. And there is the issue, GPS
coordinates come in WGS84 and so are in degrees, which is not a good unit for
buffering. 

{% highlight java %}
 private Geometry buffer(Geometry geom, double dist) {
    Geometry buffer = geom.buffer(dist);
    return buffer;
 }
{% endhighlight %}

So the method needs to take into account the projection of the input features
and if necessary reproject them into a "good" projection and then buffer them
and finally project the result back to the original projection. Fortunately the OGC and GeoTools thought that this might be a useful function to have. So there is provision for AUTO projections. If you create a projection with the code AUTO:42001,x,y then you get a UTM projection centred on the longitude you provide and in the correct half of the world based on the latitude, which in this case is exactly what we need.

{% highlight java %}
   if (!(origCRS instanceof ProjectedCRS)) {
      
      Point c = geom.getCentroid();
      double x = c.getCoordinate().x;
      double y = c.getCoordinate().y;
     
      String code = "AUTO:42001," + x + "," + y;
      // System.out.println(code);
      CoordinateReferenceSystem auto;
      try {
        auto = CRS.decode(code);
         toTransform = CRS.findMathTransform(
         DefaultGeographicCRS.WGS84, auto);
         fromTransform = CRS.findMathTransform(auto,
         DefaultGeographicCRS.WGS84);
         pGeom = JTS.transform(geom, toTransform);
      } catch (MismatchedDimensionException | TransformException
        | FactoryException e) {
          e.printStackTrace();
      }
 
  }
{% endhighlight %}

Once you have transformed the geometry it's trivial to call the buffer method and then reproject back with the matching inverse transform (fromTransform) to produce the final geometry.

The whole program can be found [here](https://gist.github.com/ianturton/9a7cfee378e7072ec3cd). 


