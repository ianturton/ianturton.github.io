---
layout: post
title: Filling with text
categories: styling geoserver geotools
---

I've been away at FOSS4GE this last week (a full post is coming on that) so this last piece of work has taken slightly longer than I had hoped but is finally finished.

I've always been envious of the typographic maps at [AxisMaps](http://store.axismaps.co.uk/) which are beautiful works of art but only cover 7 cities none of which I'm prepared to move to just to get a nice map of where I live. Now I've always known that if I want I could make a map like theirs but I don't have the hundreds of hours (or the patience) to do it.

So one day I was thinking about ways to automate the process. I'm pretty sure mine won't be works of art but I should be able to get something nice to look at anyway. Fortunately for me GeoTools (and hence GeoServer) can generate what is known as a `GraphicFill` in the [OGC](http://www.opengeospatial.org/) [SLD](http://www.opengeospatial.org/standards/sld) world. That is you can fill a polygon using an externally defined graphic, you can also use them to "draw" a line or represent a point. The authors of the SLD specification were thinking of people wanting to use custom hash marks or geology symbols, but the specification is fairly lax as to what can go in there. 

So my first plan was to use the [existing facility to import an SVG file](http://docs.geoserver.org/stable/en/user/styling/sld-extensions/pointsymbols.html#external-graphics) and use that. But this meant that I had to create an SVG file for each name that I wanted to use in map and that could be thousands. I toyed with writing a program to read a shapefile and generate SVG from all the values in an attribute but it didn't seem like an elegant solution.

So I wrote a [`TextGraphicFactory`](https://gitlab.com/snippets/6682) which
implements `ExternalGraphicFactory` and registered it using a file called
`META-INF/services/org.geotools.renderer.style.ExternalGraphicFactory` which
just contains the class name. Once the code is compiled all you need to do is
drop it into a GeoServer installation's `WEB-INF/lib` folder and GeoServer can
immediately start using text as a fill in polygons. 

The URL format is designed to allow you to specify a piece of text to use; and optionally the font, size, background and foreground colours to use when drawing the label. The trick is to mark the image type as (the invalid) `image/text` mime type.
So all of the following are valid:

    http://Pennsylvania
    http://Arial#Texas
    http://Arial#fg=FF0000#bg=00FF00#size=10#Texas

The first uses the text string Pennsylvania, the second draws Texas using the Arial font (if available), the final one draws Texas in red on a green background using a 10pt font.

As with many parts of the GeoServer SLD system you can also specify an attribute name in the URL instead of a fixed string.

{% highlight xml %}
     <sld:Rule>
        <sld:PolygonSymbolizer>
        <sld:Fill>
          <sld:GraphicFill>
           <sld:Graphic>
             <ExternalGraphic>
                <OnlineResource xlink:type="simple" 
                      xlink:href="http://URW Gothic L Demi#size=9#${STATE_NAME}" />
                <Format>image/text</Format>
              </ExternalGraphic>
              <sld:Size>0</sld:Size>
            </sld:Graphic>
          </sld:GraphicFill>
        </sld:Fill>
        <sld:Stroke/>
      </sld:PolygonSymbolizer>
    </sld:Rule>
{% endhighlight %}

You end up with a map like:

![map](/images/fonts.png) - you can try it out [here](http://geoserver.ianturton.com/topp/wms?service=WMS&version=1.1.0&request=GetMap&layers=topp:states&styles=state_names_font&bbox=-124.73142200000001,24.955967,-66.969849,49.371735&width=768&height=330&srs=EPSG:4326&format=application/openlayers). It's looking nice, I'm sure with time I can find a nicer font, and colour it in etc.

The only remaining problem I face is that the background colouring doesn't work perfectly as you can see here:
![map2](/images/bgfonts.png) - again you can explore [here](http://geoserver.ianturton.com/topp/wms?service=WMS&version=1.1.0&request=GetMap&layers=topp:states&styles=state_names_font_colors&bbox=-124.73142200000001,24.955967,-66.969849,49.371735&width=768&height=330&srs=EPSG:4326&format=application/openlayers)

So there is a special prize for anyone who can work out where the missing pixel is coming from or going to. 

Watch this space as I move closer to an automated work flow for typographic maps I'll keep you informed.
