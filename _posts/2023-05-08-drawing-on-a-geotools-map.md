---
layout: post
title: Drawing a line on a GeoTools Map
date: 2023-05-08
categories: GeoTools
---
# Drawing a line on a GeoTools Map

As anyone following the dismal news out of the UK recently will know we had some sort of royal extravaganza 
down south in England this weekend, so with nothing better to do (and an extra day off) I decided to do some 
playing with GeoTools. This was mostly motivated by the work I had already done in answering this 
[gis.stackexchange.com question](https://gis.stackexchange.com/q/458918/79) about
how to draw a line on top of a map. It seems that there isn't much about how to do this in the [GeoTools
documentation](https://docs.geotools.org/stable/userguide/unsupported/swing/index.html).

So I scratched my head and dredged up what I could remember about swing and particularly about the GeoTools 
swing module and came up with some code that answered the immediate question which was why the OP got many 
layers in the map rather than one. I decided that this might be useful for other people so I tidied the code 
up and created a [small project](https://gitlab.com/ianturton/geotools-tools) that contains a 
`DigitizerAction` and a `Digitizer` class which is the actual tool. It's pretty simple all it does is place a 
series of dots on the screen and then generates a `LineString` which is added to a list, which is then used to 
generate a new `FeatureLayer` and removes the old layer (if it exists). 

I finished up by adding a little demo program which adds a draw button to the toolbar and displays the US 
States for you to draw over.

![A screenshot of the demo](/images/draw.png "A screenshot of the demo")

All you do is click the draw button, then each click on the map will add a point to the current line, a double 
click finishes the line and forces a redraw of the screen with the line now in red.

## Details

For anyone who's trying to create a new tool for their swing application with GeoTools here is a little more 
on how it works.

### Action

We need to create an `Action` to tell swing what we plan to do, I called mine `DigitizerAction` and made it 
extend `MapAction` which Michael Bedward (the original author of the gt-swing module) helpfully provided to 
save us typing (or pasting) in a lot of boiler plate code. All I have to provide is some code to initialise 
the action's icon, name etc and an `actionPerformed` method to set the tool up to actually do something when 
the button is clicked.

### Tool

Again to save time and effort the `Digitizer` tool extends `CursorTool` which extends `MapMouseAdapter` so we 
don't need to worry about how to listen to the mouse's movements or how to get a real world position from a 
mouse click. Much of the code is either set up or book keeping. For set up we need to generate a `FeatureType` 
for the `Feature`s we'll be building later, and a style so they show up on the map (a more advanced tool might 
let the user override that default style). The only other thing to take care of in the constructor is setting 
the cursor to a simple cross hair.

~~~java
   public Digitizer() {
        SimpleFeatureTypeBuilder b = new SimpleFeatureTypeBuilder();
        b.setName("LineFeature");
        b.add("line", LineString.class);
        SimpleFeatureType TYPE = b.buildFeatureType();
        featureBuilder = new SimpleFeatureBuilder(TYPE);
        geometryFactory = JTSFactoryFinder.getGeometryFactory(JTSFactoryFinder.EMPTY_HINTS);
        style = SLD.createLineStyle(Color.red, 2.0f);

        ImageIcon imgIcon = new ImageIcon(getClass().getResource(ICON_IMAGE));
        cursor = new Cursor(Cursor.CROSSHAIR_CURSOR);
    }
~~~

The class also has some fields that we'll need later `lastX` and `lastY` which is the position of the last 
click, an `ArrayList` of `Coordinate`s which are the real world positions of the current line, and a list of 
`SimpleFeature`s which hold the lines that we have already drawn. We need to keep track of the previous 
features as the display layer is recreated every time we add a line.

The actual interaction with the user all occurs inside the `onMouseClicked` method which is called each time a 
mouse button is clicked.

~~~java
    public void onMouseClicked(MapMouseEvent e) {

        if (e.getClickCount() > 1) { // was it a double click
            drawTheLine(positions);
            first = true;
        } else { // add a new point
            DirectPosition2D pos = e.getWorldPos();

            positions.add(new Coordinate(pos.x, pos.y));
            // Put a marker at each digitized point
            Graphics graphics = (Graphics2D) ((JComponent) getMapPane()).getGraphics().create();
            int x = e.getX();
            int y = e.getY();
            if (!first) {
                graphics.drawLine(lastX, lastY, x, y);
            }
            first = false;
            lastX = x;
            lastY = y;
            graphics.fillRect(x - 3, y - 3, 6, 6);
        }
    }
~~~

Here we first check if the user has clicked twice within the system time limit (so it is a double click), if 
it is we call the `drawTheLine` method on the positions list to add the line to the screen, we'll look at that 
in a moment. We also reset the `first` flag to say that the next click (if there is one) is the first in a 
line. 

If the user only clicked once (or this is the first click of a double click) we will go through the `else` 
branch, where we get the world position of the click and add that to our list of coordinates. We then grab a 
`graphics` from our map pane to draw a temporary mark so the user knows we're listening and have seen their 
click, here we need the X and Y pixel coordinates. If this is not the first point in the line we draw a line 
from the last point (`lastX`, `lastY`) to the current point (`x`, `y`) and then we draw a point at the current 
point (`x`, `y`). We also make a note of this point for next click to be the start of the line and note that 
we now have previous point by making `first` false.

The last remaining step is to draw lines on the map as `SimpleFeature`s, this is done in `drawTheLine` where 
we generate a new `LineString` using the `GeometryFactory`, we then add that `LineString` to the 
`FeatureBuilder` and create a new `SimpleFeature` from it. Note that we leave the `id` set to `null` so it 
generates a new `FID` for each feature. The feature is then stored in the `features` list, the existing layer 
is removed from the map (to prevent us ending up with an ever increasing number of map layers). Then we create 
a new `FeatureLayer` using the `DataUtilities.collection` method to convert our list of `SimpleFeature`s to a 
`SimpleFeatureCollection` and applying the style we made earlier. Finally, we reset the `positions` list to 
empty to be ready to store the next line for the user.


## Usage 

If you want to use this in your own map you can simply do the following:

~~~
    mapFrame = new JMapFrame();
    mapFrame.enableToolBar(true);
    JToolBar toolBar = mapFrame.getToolBar();
    DigitizerAction d = new DigitizerAction(mapFrame.getMapPane());
    JButton btn = new JButton(d);
    toolBar.addSeparator();
    toolBar.add(btn);
~~~

You can then get the list of features by using `d.getFeatures()` if you want to provide a save function or to 
send them to some other store.
