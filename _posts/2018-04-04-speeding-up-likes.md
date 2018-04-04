---
layout: post
title:  "Speeding up like queries in PostGIS (and GeoServer)"
date:  2018-04-04 
categories: postgis
---

I often use `like` queries in PostGIS and with GeoServer into a PostGIS
datastore. But recently a trainee on course asked if they were fast enough to
allow them to use in a CQL query to allow the end user to generate new layers on
the fly. 

After some Googling we discovered that they probably are but that there are a
few tricks you need to use to get the benefits of the index. 

I had always indexed any attribute (column) that I intended to use in the
styling of a layer or that would be queried in requests. But it turns out that
might not be good enough if you are making `like` queries. 

To test this out I'm using the Ordnance Survey open data [Vector Map
District](https://www.ordnancesurvey.co.uk/business-and-government/products/vectormap-district.html)
dataset for the whole of Great Britain, it's large but not enormous. For example
the roads table has 2.8 million road segments of which 800 thousand are named.
Here is the "default" index.

{% highlight sql %}
CREATE INDEX idx_distinictive_name
  ON vmd.road
  USING btree
  (distinctivename COLLATE pg_catalog."default");
{% endhighlight %}

So, I ran a typical query to find how many roads are named after some sort of
Oak tree:

{% highlight sql %}
select distinctivename, count(ogc_fid) 
from vmd.road 
where distinctivename
like '%oak%' 
group by distinctivename order by count desc;
{% endhighlight %}

On my desktop machine this takes 162 milliseconds to run, which is not too bad
but it could probably be better. If we look at the query plan:

~~~~
Sort  (cost=83988.80..83988.97 rows=67 width=21)
  Sort Key: (count(ogc_fid)) DESC
  ->  Finalize GroupAggregate  (cost=83978.87..83986.77 rows=67 width=21)
      Group Key: distinctivename
      ->  Gather Merge  (cost=83978.87..83985.82 rows=56 width=21)
          Workers Planned: 2
          ->  Partial GroupAggregate  (cost=82978.84..82979.33 rows=28 width=21)
              Group Key: distinctivename
              ->  Sort  (cost=82978.84..82978.91 rows=28 width=17)
                    Sort Key: distinctivename
                    ->  Parallel Seq Scan on road  (cost=0.00..82978.17 rows=28 width=17)
                          Filter: ((distinctivename)::text ~~ '%oak%'::text)
~~~~

There is no mention of an index! Wow! I'd never really checked on this before so
this was a bit of a shock. So after a bit of strategic googling I found this
[stackoverflow question and
answer](https://stackoverflow.com/questions/1566717/postgresql-like-query-performance-variations),
which recommended that I add the `pg_trgm` extension so that I had GIN and GiST
trigram indexes that support all `like` and `ilike` patterns.

{% highlight sql %}
CREATE EXTENSION pg_trgm

CREATE INDEX idx_distinictive_name2
  ON vmd.road
    USING gin
      (distinctivename COLLATE pg_catalog."default" gin_trgm_ops);
{% endhighlight %}

Now the query takes a mere 20 milliseconds and the query plan looks a lot
better with an index in use front and centre:

~~~~
Sort  (cost=284.30..284.47 rows=67 width=21)
  Sort Key: (count(ogc_fid)) DESC
  ->  GroupAggregate  (cost=281.10..282.27 rows=67 width=21)
        Group Key: distinctivename
        ->  Sort  (cost=281.10..281.26 rows=67 width=17)
              Sort Key: distinctivename
              ->  Bitmap Heap Scan on road  (cost=16.52..279.07 rows=67 width=17)
                    Recheck Cond: ((distinctivename)::text ~~ '%oak%'::text)
                    ->  Bitmap Index Scan on idx_distinictive_name2  (cost=0.00..16.50 rows=67 width=0)
                          Index Cond: ((distinctivename)::text ~~ '%oak%'::text)
~~~~


All of these speed ups are passed directly to GeoServer when you are using a
PostGIS datastore as these queries are passed down to the database to handle. So
it pays to make sure you have not just indexed an attribute but that you are
using the right index for the type of queries you expect to see.

For the larger [Vector Map
Local](https://www.ordnancesurvey.co.uk/business-and-government/products/vectormap-local.html) data using `ILIKE` since the Ordnance Survey used all caps for the road names, the speed up is from 760ms to 122ms.
