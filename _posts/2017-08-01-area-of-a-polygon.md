---
layout: post
title:  "Calculating the area of a polygon"
categories: geotools, projections
---

One of the recurring questions on GIS stackexchange is "What units is the area
calculated by JTS `getArea()`". It doesn't seem to matter how many times people
say that these is no answer to this as it depends on the projection of your
data. The question will not die, so I cooked up some code that should give a
close-ish answer for most polygons.

As with most of these questions the trick is to convert your polygon to a flat
cartesian plane (this is where JTS works best). We can use the GeoTools auto
projection (assuming the polygon is small enough) and then simply call
`.getArea()` method.

{% highlight java %}
private Measure<Double, Area> calcArea(SimpleFeature feature) {
    Polygon p = (Polygon) feature.getDefaultGeometry();
    Point centroid = p.getCentroid();
    try {
      String code = "AUTO:42001," + centroid.getX() + "," + centroid.getY();
      CoordinateReferenceSystem auto = CRS.decode(code);

      MathTransform transform = CRS.findMathTransform(DefaultGeographicCRS.WGS84, auto);

      Polygon projed = (Polygon) JTS.transform(p, transform);
      return Measure.valueOf(projed.getArea(), SI.SQUARE_METRE);
    } catch (MismatchedDimensionException | TransformException | FactoryException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    return Measure.valueOf(0.0, SI.SQUARE_METRE);
  }
{% endhighlight %}


Note how I have returned a `Measure` instead of a raw double, so now any one 
using the method "knows" automatically that the answer is an area and it is in
square metres. 

This is also handy if you want to display your result in another unit:

{% highlight java %}
    Measure<Double, Area> a = me.calcArea(feature);
    System.out.println(a);

    System.out.println(a.to(NonSI.HECTARE));

    Unit<Area> sq_km = (Unit<Area>) SI.KILOMETER.pow(2);
    System.out.println(a.to(sq_km));

    Unit<Area> sq_mile = (Unit<Area>) NonSI.MILE.times(NonSI.MILE);
    System.out.println(a.to(sq_mile));


    Unit<Area> acre = (Unit<Area>) NonSI.MILE.divide(8.0).times(NonSI.FOOT).times(66.0);
    UnitFormat.getInstance().label(acre, "acre");
    System.out.println(a.to(acre));

{% endhighlight %}

Produces this expected output, where we can use predefined units like Hectare
(and the less common Are) and define our own units like kilometre squared and
acre. According to QGIS identify it should be 103,888.317 km² for a large
polygon. 

{%highlight text%}
1.025113765431267E11 m²
102511.3765431267 km²
39579.86375845866 mi²
1.025113765431267E7 ha
2.5331112805413544E7 acre
{% endhighlight %}

For a smaller polygon I get 46.833 ha in QGIS and 46.901 ha which is close
enough for most problems.
