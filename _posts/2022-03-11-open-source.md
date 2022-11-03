---
layout: post
title: Open Source and Sanctions
date: 2022-03-11
categories: foss
---

# Some Thoughts On Open Source Programs and Sanctions

To start this post first let me state that this represents my personal view and may or may not be the view of 
any of the projects I mention and that I completely and utterly condemn the Russian invasion of Ukraine.

In the last 2 weeks since Russia invaded Ukraine I have been seeing a number of tweets and other comments that 
a) ESRI should pull out of Russia and invalidate the licences it has sold in the country, and 
b) (usually from different people) what about the open source community? Should they ban downloads from 
   Russia.

**TL;DR**: I'm firmly on the side of no, there is nothing open source programs and communities can do to 
prevent people they don't like using their code to do things they don't approve of.

If you're still reading then let me lay out some of my thinking, again this makes more sense if you remember 
that I'm old so I've seen most of these discussions in some form or another before. I can remember when the 
open source community went to court in the USA to try to determine that [code was free 
speech](https://hoffmang9.github.io/free-speech/the-history-code-is-free-speech.html) as at the time it was 
illegal to export "munitions" in the form of encryption software from the USA. Interestingly we are still 
seeing remnants of this in (for example) [Oracle's JDK and JDBC 
libraries](https://blog.cleverelephant.ca/2006/12/not-so-free-client-libraries.html). There is a certain 
arrogance to this sort of blocking moves. It screams (at least to me) "We Americans are so smart no puny 
European (or North Korean or ...) can program like we do!" But I don't think that's true and I have worked 
with a lot of European, Russian, and other nationality programmers over the years and I have never noticed 
that they are in any way dumber than the Americans I've worked with. So I think that banning countries from 
downloading programs is a stupid idea, also it's very hard to do well and make actually work in a world with 
easy VPNs. And does any one really think that say North Korea will be defeated by a click through licence that 
asks them not to do something. 

So in the abstract I don't think banning will work, in the case of open source software it is doubly 
impossible because we don't even know how many users we have or where they are or even who is distributing our 
code. As Jáchym Čepický said on twitter:

> You do not understand the concept of open source software do you? Nobody can block the software to be 
> downloaded and used for any purpose - even if it was evil. As community member, you can refuse support, you 
> can cancel some other members. But nobody really "owns" the software.

I've watched some of the other FOSS4G communities discuss this (often at some length) and essentially come to 
the same conclusion. QGis decided to put a notice in the News Tab of the new release, and someone promptly 
complained that they didn't want "politics" in their software, Leaflet changed it's [home 
page](https://leafletjs.com/) to make clear their concerns for Vladimir Agafonkin who started the project 11 
years ago and has been forced to leave his home in Ukraine due to the invasion. These are both great responses 
and I fully support them, GeoServer and GeoTools haven't done anything similar, partly because no one raised 
the issue and partly because making a statement will not actually change anything, so I'd rather donate money 
to charities supporting Ukrainian refugees such as the https://savelife.in.ua/en/donate/ charity, or the 
[Ukrainian Red Cross](https://redcross.org.ua/en/), where it will actually make life (marginally) better for 
someone. 

Finally, this leads us to the old argument from the ["postmodern 
geographers"](https://www.routledge.com/Ground-Truth-The-Social-Implications-of-Geographic-Information-Systems/Pickles/p/book/9780898622959) 
(that I left academia to avoid) who always felt that GIS was a tool of the military industrial complex and so 
could never be used for good. To which I've always said so what, many things I use in every day life were 
developed by the military (or for the military), there is a reason for that the military has an almost 
unlimited budget (when did you last see a collection tin for a new tank rather than a new MRI machine?) so 
they can spend absurd amounts of money on research and development. More than once I've been happy to take 
that money and use it to develop open source computer programs that all of humanity can use (and prevent them 
buying more explosive toys with the cash instead). Does that mean I have blood on my hands when the UK Army 
uses (say) GeoServer to plan it's deployments in Afghanistan? Or would it have been worse if I hadn't 
cooperated and they had used another map server or just paper maps. Am I concerned to learn that [North Korea 
uses GeoServer, GeoTools and PostGIS](https://endofcap.tistory.com/1960)? In both cases no, I am happy that we 
have another satisfied user and I hope they contribute back but like most of our users I expect to never hear 
from them once. 

In conclusion, there is no way for anyone to truly block access to open source software, in fact that is 
rather the point of open source software, and if there was a way to block people there is every chance that a 
government somewhere would object to me (or my country) or something about me to block my use of some 
software. 

