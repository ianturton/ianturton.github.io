---
layout: post
title:  "Interesting Windows Issue with Git and Mvn"
date:  2018-08-27 
categories: windows
---


During this morning's GeoServer developers workshop, I was forced to spend more
time in contact with windows based machines than I normally like. I ran into an
bug which I'll document now for the benefit of anyone else trying to set up a
windows java build environment.

When you install Git for Windows it sets
`HKEY_CURRENT_USER\Software\Microsoft\Command Processor\Autorun` in the
registry to use it's `cmd` command (and it includes a space in the path). (I
don't know why it does this, and I don't really care!) But when this happens,
`mvn` will complain that `c:\Program ` is not an executable program. After
extensive debugging I discovered the problem wasn't the `JAVA_HOME` or
`JAVA_PATH` which is where I expected it to be, it was whenever maven called the
windows `cmd`. 

The fix is to use `regedit` to remove the
`HKEY_CURRENT_USER\Software\Microsoft\Command Processor\Autorun` from the
registry. See this
[question](https://stackoverflow.com/questions/30881533/maven-surefire-plugin-error-in-starting-fork-while-building-project-with-intel)
on StackExchange for more discussion.
