---
layout: post
title:  "Converting CQL to OGC Filters"
date:   2015-03-18 19:35:00
categories: geotools code ogc
---

A user on the GeoTools user list was trying to work out how to generate a full
XML OGC Filter representation from a simpler CQL filter. The CQL filter could
be used in a WFS Get request but when he switched to using Post requests he needed to use an OGC filter. While in some cases it is quite easy to convert a CQL filter in others this is a complex procedure. So I put together a quick GeoTools program to do the conversion for you.

{% highlight java %}
package org.ianturton.cookbook.filters;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.geotools.filter.text.cql2.CQL;
import org.geotools.filter.text.cql2.CQLException;
import org.opengis.filter.Filter;

public class CQLToOGC {

  public static void main(String[] args) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    String line;
    org.geotools.xml.Configuration configuration = new org.geotools.filter.v1_0.OGCConfiguration();
    org.geotools.xml.Encoder encoder = new org.geotools.xml.Encoder(
        configuration);
    encoder.setIndenting(true);

    while (!(line = reader.readLine()).isEmpty()) {
      try {
        Filter filter = CQL.toFilter(line);
        // System.out.println("\t" + filter);
        encoder.encode(filter, org.geotools.filter.v1_0.OGC.Filter, System.out);
      } catch (CQLException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
    }
  }

}
{% endhighlight %}


It just reads standard in until it gets a blank line. It then writes the XML out to standard out. I'm  an old school UNIX user.

So typing:

> prop = 23

gives a result of:`

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?><ogc:Filter xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml">
  <ogc:PropertyIsEqualTo>
    <ogc:PropertyName>prop</ogc:PropertyName>
    <ogc:Literal>23</ogc:Literal>
  </ogc:PropertyIsEqualTo>
</ogc:Filter>
{% endhighlight %}

or

> INTERSECTS(SP_GEOMETRY, POLYGON ((142578.64599609 252217.79003906, 73781.897460938 141983.61767578, 287078.38037109 146764.85888672, 142578.64599609 252217.79003906)))

gives a result of:

{% highlight xml%}
<?xml version="1.0" encoding="UTF-8"?>
<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gml="http://www.opengis.net/gml">
  <ogc:Intersects>
    <ogc:PropertyName>SP_GEOMETRY</ogc:PropertyName>
    <gml:Polygon>
      <gml:outerBoundaryIs>
        <gml:LinearRing>
          <gml:coordinates>142578.64599609,252217.79003906 73781.897460938,141983.61767578 287078.38037109,146764.85888672 142578.64599609,252217.79003906</gml:coordinates>
        </gml:LinearRing>
      </gml:outerBoundaryIs>
    </gml:Polygon>
  </ogc:Intersects>
</ogc:Filter>
{% endhighlight %}


