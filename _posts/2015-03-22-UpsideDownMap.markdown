---
layout: post
title: "XKCD and the Upside Down Map"
date: 2015-03-22 15:00
categories: geotools maps code xkcd
---

[XKCD](http://xkcd.com) [nerd sniped](https://xkcd.com/356/) me this week with a fantastic comic containing an upside down map.

![upside down map](http://imgs.xkcd.com/comics/upside_down_map.png)

My immediate thought was "I wonder if I can make that?" - After all I'm a geographer I understand how this is done, right? 

Turns out it was harder than I thought. Rotating features is pretty easy, all I needed to do was extend some old code I had for a [GeoTools](http://geotools.org) function that used an [affine transformation](http://en.wikipedia.org/wiki/Affine_transformation) to scale geometries, that I used to make discontinuous cartograms, to implement rotation. Unfortunately I couldn't find that code so I started from scratch using this [tutorial](http://docs.geotools.org/latest/userguide/tutorial/function.html). It is actually very easy to extend GeoTools (and hence [GeoServer](http://geoserver.org)) with new functions. 
To start with you declare a class that extends `FunctionImpl` and provides a static `FunctionName` that defines the return type and parameter types for the function. 

{% highlight java %}
    public class FilterFunction_affineTransform extends FunctionImpl implements
    		GeometryTransformation {
    
    	public static FunctionName NAME = new FunctionNameImpl("affineTransform",
    			Geometry.class, parameter("geometry", Geometry.class), parameter(
    					"offsetX", Double.class), parameter("offsetY", Double.class),
    			parameter("scaleX", Double.class), parameter("scaleY", Double.class),
    			parameter("theta", Double.class));
{% endhighlight %}

After that it's a simple case of overriding the `evaluate` method:

{% highlight java %}

    public <T> T evaluate(Object feature, Class<T> context) {
    		Geometry geom = getExpression(0).evaluate(feature, Geometry.class);
    		Double offsetX = getExpression(1).evaluate(feature, Double.class);
    		if (offsetX == null) {
    			offsetX = 0d;
    		}
    		Double offsetY = getExpression(2).evaluate(feature, Double.class);
    		if (offsetY == null) {
    			offsetY = 0d;
    		}
    		Double scaleX = getExpression(3).evaluate(feature, Double.class);
    		if (scaleX == null) {
    			scaleX = 0d;
    		}
    		Double scaleY = getExpression(4).evaluate(feature, Double.class);
    		if (scaleY == null) {
    			scaleY = 0d;
    		}
    		Double theta = getExpression(5).evaluate(feature, Double.class);
    		if (theta == null) {
    			theta = 0d;
    		}
    
    		if (geom != null) {
    
    			Coordinate ancorPoint = geom.getCentroid().getCoordinate(); // or some
    			// other point
    			AffineTransform affineTransform = AffineTransform.getTranslateInstance(
    					ancorPoint.x, ancorPoint.y);
    
    			affineTransform.concatenate(AffineTransform.getRotateInstance(theta));
    			affineTransform.concatenate(AffineTransform.getScaleInstance(scaleX,
    					scaleY));
    			affineTransform.concatenate(AffineTransform.getTranslateInstance(offsetX,
    					offsetY));
    			affineTransform.concatenate(AffineTransform.getTranslateInstance(
    					-ancorPoint.x, -ancorPoint.y));
    			MathTransform mathTransform = new AffineTransform2D(affineTransform);
    			Geometry offseted = null;
    			try {
    				offseted = JTS.transform(geom, mathTransform);
    			} catch (MismatchedDimensionException | TransformException e) {
    				// TODO Auto-generated catch block
    				e.printStackTrace();
    			}
    			return Converters.convert(offseted, context);
    		} else {
    			return null;
    		}
    	}

{% endhighlight %}

The only tricky part is that you have to move to the centroid of the geometry before you start scaling or rotating the shape otherwise it will use the corner which looks odd. It is a little unwieldy to use at present as you have to specify all 5 parameters even if you only want to rotate the geometry. I plan to tidy it up into four functions before I merge it into the GeoTools code base. 

Using the new function requires that you add a couple of files to the resources folder of your project which is all covered in the tutorial. Then you can just use it directly (as I have) or from an SLD file in GeoServer if you prefer. I wrapped the function in some code to read in and write out a shapefile:

{% highlight java %}
SimpleFeatureType schema = featureReader.getFeatureType();
		List<SimpleFeature> feats = new ArrayList<SimpleFeature>();
		Literal fallback;
		List<Expression> parameters = new ArrayList<Expression>();
		PropertyName lit = ff.property(schema.getGeometryDescriptor().getName());
		Literal offsetX = ff.literal(0.0d);
		Literal offsetY = ff.literal(0.0d);
		Literal scaleX = ff.literal(1.0d);
		Literal scaleY = ff.literal(1.0d);
		Literal theta = ff.literal(Math.PI);
		parameters.add(lit);
		parameters.add(offsetX);
		parameters.add(offsetY);
		parameters.add(scaleX);
		parameters.add(scaleY);
		parameters.add(theta);
		FilterFunction_affineTransform transform = new FilterFunction_affineTransform(
				parameters, null);
		try {
			while (featureReader.hasNext()) {
				SimpleFeature feature = featureReader.next();
				Geometry result = transform.evaluate(feature, Geometry.class);
				feature.setDefaultGeometry(result);
				feats.add(feature);
			}
		} catch (IllegalArgumentException | NoSuchElementException | IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				featureReader.close();
				input.dispose();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
{% endhighlight %}

So can I recreate XKCD's map with this function? First I had to find some data, luckily USGS came to my aid with a [shapefile of the continents](http://pubs.usgs.gov/of/2006/1187/basemaps/continents/). 
My first attempt was nothing like the XKCD map as I had Asia and Europe as separate features, Great Britain was attached to Europe & New Zealand and Micronesia crossed the dateline and rotated way off to the right as a result. However once I had done some splitting and merging in [QGis](http://qgis.org) I could generate this map:

![upside_down_cont.png](https://raw.githubusercontent.com/ianturton/ianturton.github.io/master/images/map.png)

As you can see it is **not** the same as XKCD's map. The main details are the same, the UK is across from North Korea but South Africa is on top of them. If I really needed to recreate his map I could use QGis to move Africa south and tidy up North America and the Canadian Islands. But I think I've been sniped enough so I'll leave that as an exercise for the reader.

