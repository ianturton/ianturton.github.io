---
layout: post
title:  "Finding anagrams of place names (in the World)"
categories: geotools fun anagram
---

As a quick follow up to [Anagrams in the
UK](https://blog.ianturton.com/geotools,/fun,/anagram/2017/12/20/anagrams.html)
I thought I'd try to do the world. 

I downloaded the
[cities1000](http://download.geonames.org/export/dump/cities1000.zip)
file from [GeoNames](http://geonames.org) which contains
all the cities with a population > 1000 or seats of adm div
(ca 150.000). I then loaded it into PostGIS using this [handy
guide](https://github.com/colemanm/gazetteer/blob/master/docs/geonames_postgis_import.md)
(the cities\* files are just a subset of the `geoname` table).

Then I just need to change the table and column names in the orginal code to use
the helpful `asciiname` column.

Results
-------

The global winner is the 13 letter Port-Saint-Pere as perpetrations. Honourable mentions to the following 12 letters:

+ Cerreto d'Asti - directorates
+ Chernomorets - chronometers
+ Dragodanesti - degradations
+ Idaho Springs - rhapsodising
+ Manderscheid - merchandised
+ Puerto Cisnes - persecutions
+ Saint-Emilion - eliminations
+ Saint-Georges - segregations
+ Seven Sisters - restivenesss
+ Solbiate Arno - elaborations
+ Villeurbanne - invulnerable

[Full results are on line](https://gitlab.com/snippets/1689735).
