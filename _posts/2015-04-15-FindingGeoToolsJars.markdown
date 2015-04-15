---
layout: post
title: Playing Hunt the jar with GeoTools
categories: geotools maven dependencies
---

One of the most commonly asked questions about GeoTools is "how do I work out which jars to include in my project?" The developers will always tell you that Maven is your friend at this point, and nearly always they are right. Maven is a fantastic tool for complex (and simple) java projects. Maven handles the situation that most frustrates users - when you add a jar you to your project you need to find and add all of the jars that it depends on. So if you added some code to import GeoTiffs into your program you have to add a reference to `gt-geotiff-12.2.jar` to you project. But then you need to know what jars does gt-cql depend on, one option is to go to the GeoTools source directory and look in the `pom.xml` file in the `/modules/plugin/geotiff` directory and then repeat for each jar you find in there. But that could take a while if there are a lot or prove a dead end if  it lists no dependencies.

However this is why the GeoTools (and other projects) use Maven, simply add the required jar to your `pom.xml` like so:

    <dependency>                                       
            <groupId>org.geotools</groupId>            
            <artifactId>gt-geotiff</artifactId>            
            <version>${geotools.version}</version>     
    </dependency>

and your project will pull in all the required dependencies for you automatically when you run maven,  Note how experienced maven (and GeoTools) users parameterise the version number so it's easy to move on the next release.       

If you absolutely must know what its dependencies are you can ask maven to look it up for you.  This uses the command:

     mvn dependency:tree       

and (a selected portion of) the result is:  

    org.geotools:gt-geotiff:jar:13-SNAPSHOT:compile                             
    +- org.geotools:gt-coverage:jar:13-SNAPSHOT:compile                         
    |  +- org.jaitools:jt-zonalstats:jar:1.3.1:compile                          
    |  \- org.jaitools:jt-utils:jar:1.3.1:compile                               
    +- javax.media:jai_imageio:jar:1.1:compile                                  
    \- it.geosolutions.imageio-ext:imageio-ext-tiff:jar:1.1.10:compile          
       +- it.geosolutions.imageio-ext:imageio-ext-utilities:jar:1.1.10:compile  
       \- javax.media:jai_codec:jar:1.1.3:compile              

Now this is all well and good when you can work out where abouts your  class lives in the GeoTools jar structure. So in the example above it wasn't too hard to guess that GeoTiff code lived in the GeoTiff module which is a plugin, or a quick Google will find the [documentation](http://docs.geotools.org/stable/userguide/library/coverage/geotiff.html)  which will tell you. Suppose you were using a more obscure class like:

    org.geotools.text.Text

I have no clue where to find this class, but I know how to find out. I came across a project called [Joops](https://code.google.com/p/joops/)      which   can look for a class by name in a collection of jar files. So first you need to download the project jar file [oops-0.9.1.jar](https://code.google.com/p/joops/downloads/detail?name=oops-0.9.1.jar&can=2&q=)   and you'll need some jars to search, I fetched the latest GeoTools release from [SourceForge](http://sourceforge.net/projects/geotools/files/latest/download?source=files)              

Then I just unpack the GeoTools jars into a convenient directory (I called mine geotools-12.2 and then ran the following command line, which basically says look for jars in ../geotools-12.2 and the oops-0.9.1.jar in this directory and execute the main method of class Which in package oops:

    java -cp "..\geotools-12.2\*;oops-0.9.1.jar" oops.Which org.geotools.referencing.CRS

which returned:

    org.geotools.text.Text: C:/Users/ian.turton/geotools-12.2/gt-metadata-12.2.jar

Problem solved so I need to add gt-metadata to my pom file if I want to use the Text class.
