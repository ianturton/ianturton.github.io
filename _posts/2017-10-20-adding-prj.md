---
layout: post
title:  "Adding a .prj file to existing data files"
categories: geotools, projections, itches
---

While teaching a GeoServer course recently, we were trying to add a collection
of tif and world files to GeoServer as an image mosaic. But the operation kept
failing as GeoServer was unable to work out the projection of the files. 

This problem can be avoided by adding a `.prj` file to the tif file to help
GeoServer out. However we had hundreds of files and a certain national mapping
agency had just assumed that everyone knew its files were in
[EPSG:27700](http://epsg.io/27700). 

Later, I worked up a quick solution to this problem. GeoTools is capable of
writing out a WKT representation of a projection and Java has no problem walking
a directory tree matching a regular expression. 

Getting the WKT of a projection is trivial:

{% highlight java %}
CoordinateReferenceSystem crs = CRS.decode("epsg:27700");
String wkt = crs.toWKT();
{% endhighlight %}



Walking the directory tree was a little trickier but uses an anonymous
method of the `Files` class `walkFileTree`

{% highlight java %}
public static ArrayList<File> match(String glob, String location) throws IOException {
    ArrayList<File> ret = new ArrayList<>();
    final PathMatcher pathMatcher = FileSystems.getDefault().getPathMatcher("glob:**/" + glob);

    Files.walkFileTree(Paths.get(location), new SimpleFileVisitor<Path>() {

      @Override
      public FileVisitResult visitFile(Path path, BasicFileAttributes attrs) throws IOException {
        if (pathMatcher.matches(path)) {
          ret.add(path.toFile());
        }
        return FileVisitResult.CONTINUE;
      }

      @Override
      public FileVisitResult visitFileFailed(Path file, IOException exc) throws IOException {
        return FileVisitResult.CONTINUE;
      }
    });
    return ret;
  }
{% endhighlight %}

The full code can be found in this 
[snippet](https://gitlab.com/snippets/1680425). The usage is pretty 
simple to just add a `.prj` file to a single file (say a shapefile):

    java AddProj epsg:27700 file.shp

Or to deal with a whole directory 

    java AddProj epsg:27700 /data/os-data/rasters/streetview/*.tif

Which adds a `.prj` file to all the `.tif` files in that directory and all 
subdirectories.

Obviously you can use other EPSG codes if your data supplier assumes that
everyone knows their projection is the only one in the world.
