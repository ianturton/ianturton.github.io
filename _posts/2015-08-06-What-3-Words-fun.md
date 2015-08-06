---
layout: post
title: Experiments with What3Words and MGRS
categories: geotools w3w
---

Like everyone else on the OSGeo Discussion list I recently learnt far more than is good for me about cell based addressing systems when a long and loud 
[discussion](https://lists.osgeo.org/pipermail/discuss/2015-July/014505.html) broke out over the merits of various systems.

Anyway one of the issues was whether when reporting an accident you would 
prefer to use [MGRS](https://en.wikipedia.org/wiki/Military_grid_reference_system)
or [What3Words](http://what3words.com/) to locate yourself if you were away from your address, or you don't have an address. Steve Swazee argued for MGRS while most of the rest of us thought W3W might have the edge. The following quote was used:


> “Somehow I do not see a dispatcher saying to a responding officer, "Shots
fired at 103132" :-)”  Carl, you are wrong.

So I thought that I could do some experimenting, first I signed up for a 
[What3Words API key](http://developer.what3words.com/) (which was nice and easy).
Then I went looking for some code to handle MGRS (not so easy it turns out) but I found [some](https://github.com/Berico-Technologies/Geo-Coordinate-Conversion-Java) which fixed up some issues with the NASA WorldWind code (like needing all of WorldWind imported).

Sadly the W3W guys don't have a Java developer yet (though I'm available) so there is no Java library (yet?) but it turns out not to be that hard to write one. My first attempt is [here](https://gist.github.com/ianturton/9d01198752b82520f602). 

Then I ran the experiment:


    start at 37.10, -112.12
    to mgrs 12SVG 00476 06553
    which becomes sparks.videotaped.televise
    and comes back to 37.100003, -112.120011
   
    then start at 4QFJ12345678
    goes to POINT (21.309433233733703 -157.91686743821978)
    which is unkind.riser.swimwear
    and back to POINT (21.309441 -157.916855)

And you know what in an emergency I think I'm going with `unkind.riser.swimwear`over `4QFJ12345678` any day. But with code to convert between the two we can let the best system win. 



