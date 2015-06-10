---
layout: post
title:  "Running just a few unit tests with Maven"
date:  Wed Jun 10 10:33:58 BST 2015
categories: mvn testing quick tip
---

While working on the issue of time zones and databases in the GeoTools code base this week, I added some new unit tests to make sure that reading dates from the database worked even if you weren't in one of the common time zones (i.e. where the Jenkins server is or most of the developers live). I then needed run these new tests to check my code changes in the different databases GeoTools supports. 

Normally I would just do something like:

    mvn test -Ponline 

which invokes the online tests (usually the database is on another machine), after checking for changed code and recompiling if necessary. But this takes a while especially for the slower databases (i.e. Oracle). I then discovered I could use a command like:

    mvn  -Ponline -Dtest=*DateOnlineTest,*DateTest test 

This does exactly the same as before in terms of building the code but only runs the tests that end with `DateOnlineTest` and `DateTest`. Obviously I'll need to run all the tests before I commit the changes but for now this is saving several minutes a time while developing.
