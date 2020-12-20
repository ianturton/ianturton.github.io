---
layout: post
title: Exploring the `JTS.smooth()` method
date: 2020-12-20
categories: geotools
---

# Exploring the `JTS.smooth()` method

While experimenting with implementing an irregular point
contour process for [GeoTools](https://geotools.org) this week
I came across the new (at least to me) method `JTS.smooth()`
method. This gets a throw away line at the bottom of the
[documentation](https://docs.geotools.org/latest/userguide/library/main/jts.html)
that tells me it takes a `geometry` and a fit value between 0 and 1,
and then uses splines to smooth the geometry.

I delighted as I had put off implementing smoothing to the end as I
thought it would be hard work, but this was easy and it worked exactly as described. But I was left wondering about what the fit value did, the docs are a little light on explanation and to be honest I get scared looking at Martin's code too closely. So I built a [small test program](https://gitlab.com/-/snippets/2052444) so I could see what happened as I varied the fit value.

![a fit of .4](/images/fit-4.png "A fit of 0.4")
![a fit of .1](/images/fit-1.png "A fit of 0.1")
![a fit of .9](/images/fit-9.png "A fit of 0.9")


As you can see I quickly discovered that lower values of fit give
"curvier" shapes. I also experimented with densification of the lines, which constrains the curve to more of the straight sections of the line.


![a dense line](/images/dense-fit.png "A smoothed dense line")


