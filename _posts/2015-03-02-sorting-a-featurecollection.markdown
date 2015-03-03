---
layout: post
title:  "Sorting a FeatureCollection"
date:   2015-03-02 17:04:44
categories: geotools snippet code
---

One of the commonly asked questions that GeoTools users have is in the use of FeatureCollections and DataStores. This post discusses how to sort a set of features based on attributes. The following code shows how to load a shapefile and the build a Query object to sort the results.

{% highlight java %}
    File file = new File("../../data/states.shp");

    FileDataStore store = FileDataStoreFinder.getDataStore(file);
    SimpleFeatureSource featureSource = store.getFeatureSource();
    SimpleFeatureType schema = featureSource.getSchema();

    Query query = new DefaultQuery(schema.getTypeName(), Filter.INCLUDE,
        new String[] { "STATE_NAME", "PERSONS", "WORKERS" });
    FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
    query.setSortBy(new SortBy[] { ff.sort("PERSONS", SortOrder.ASCENDING) });
    SimpleFeatureCollection features = featureSource.getFeatures(query);

    SimpleFeatureIterator features2 = features.features();
    try {
      while (features2.hasNext()) {
        SimpleFeature next = features2.next();
        System.out.println("\t"+next.getAttribute("STATE_NAME")+": "+next.getAttribute("PERSONS"));


      }
    } finally {
      features2.close();
    }
{% endhighlight %}

Running this program will produce the following output:

	  Wyoming: 453588.0
	  Vermont: 562758.0
	  District of Columbia: 606900.0
	  North Dakota: 638800.0
	  Delaware: 666168.0
	  South Dakota: 696004.0
	  Montana: 799065.0
    [....]
	  Illinois: 1.1430602E7
	  Pennsylvania: 1.1881643E7
	  Florida: 1.2937926E7
	  Texas: 1.712202E7
	  New York: 1.8235907E7
	  California: 2.9760021E7
	
