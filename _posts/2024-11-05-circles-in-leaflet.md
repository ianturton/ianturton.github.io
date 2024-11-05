---
layout: post
title: Adjustable, draggable circles around markers in leaflet
date: 2024-11-05
categories: leaflet
---

I recently needed to implement a way of showing the uncertainty of a marker in a web map (the final 
application isn't ready yet) and while I found a bunch of tutorials and stackoverflow answers that covered 
parts of this I couldn't find a single page on how to do it. So I'm going to write it up here so that next 
time I need to do this a search will find this. 

**TL;DR;** You can see a simple demo [here](https://www.ianturton.com/demos/circles/circles.html), and here's 
a picture to show you what I'm talking about.

![A map with uncertain markers](/images/circles.png "opt title")

There are 3 markers (in my app anyway) and they are represented using a coloured flag. At its simplest the 
user can just pick a position and if they are happy with that move on to the next step (in the image above 
this is the blue flag). If however they are less sure of the location they can double click on the marker 
which will add a 100m circle (in a matching colour) around the point (the green flag above). Clicking on the 
circle will display a popup which allows them to adjust the radius of the circle (the red flag above). Also at 
any time the user can click on a flag and drag it (and it's circle) to a new position on the map.

~~~js
function addMarker(n) {
    name = n;
    if (lastClick) {
        L.DomUtil.removeClass(map._container, `${lastClick}-flag-cursor-enabled`);
    }
    lastClick = names[name];
    if (!positions[names[name]]) {
        L.DomUtil.addClass(map._container, `${names[name]}-flag-cursor-enabled`);
        map.on('click', setMarker)
    } else {
        map.panTo(positions[names[name]].getLatLng());
    }
    if (Object.values(positions).length == 3) {
      // proceed to remainder of the app
    }
}
~~~

When the user clicks on one of the buttons, `addMarker` is called, this clears the previous cursor if it was 
set and then if this colour of marker hasn't been set changes the cursor to match the flag we are adding or 
pans to that marker if it has been placed on the map. Then we attach the `setMarker` method to the map's click 
event, so when they click we can place a marker there.

~~~js
function setMarker(e) {
    map.removeEventListener("click", setMarker, false);
    if (!positions[names[name]]) {
        var icon = L.icon({
            iconUrl: icons[names[name]],
            iconSize: [30, 30],
            iconAnchor: [20, 27],
        });
        lat = e.latlng.lat;
        lon = e.latlng.lng;
        //Add a marker to show where you clicked.
        var latlng = L.latLng(lat, lon);
        var marker = new L.marker(latlng, {
            icon: icon,
            title: labels[names[name]],
            draggable: false,
            clickable: true,
            autoPan: true,
        }).addTo(map);
        marker.on('dblclick', (e) => {
            addCircle(e.target);
        });
        marker.on('click', mapClickListen);
        /* this is all to work around dragend triggering a click
         * see https://gis.stackexchange.com/questions/190049/leaflet-map-draggable-marker-events
         */
        marker.on('dragstart', function(e) {
            console.log('marker dragstart event');
            marker.off('click', mapClickListen);
        });
        marker.on('dragend', (e) => {
            e.target.dragging.disable();
            //pointsValid();
            marker.on('click', mapClickListen);
        });
        positions[names[name]] = marker;

    } else {
        map.panTo(positions[names[name]].getLatLng());
    }
    L.DomUtil.removeClass(map._container, `${names[name]}-flag-cursor-enabled`);
}
~~~

Again, we check if the marker has already been placed (I'm paranoid) and if not go ahead and create a flag 
icon with the correctly coloured image. The `IconAnchor` makes sure that the base of the flag pole is placed 
on the click location. Then we create a new `Marker` using the icon at the latitude and longitude of the 
click, we set it to be clickable but not draggable. The idea is (was) that the user should need to click on a 
marker to move it, which works but the end of the drag seems to click on the marker again so it never turns 
off. So I found a [workaround from 2016 to the 
bug](https://gis.stackexchange.com/questions/190049/leaflet-map-draggable-marker-events) and which was 
apparently fixed some years ago but I can't seem to make it work. Any way the key step is the add `addCircle` 
to the double click event. 


~~~js
function addCircle(marker) {
    name = names[marker.options.title];
    if (!circles[name]) {
        const popup = document.createElement("div");
        popup.innerHTML = 'adjust radius ';
        const spinner = document.createElement("INPUT");
        spinner.id = name;
        spinner.setAttribute("type", "number");
        spinner.setAttribute("min", "10");
        spinner.setAttribute("max", "200");
        spinner.setAttribute("step", "10");
        spinner.setAttribute("value", "100");
        spinner.addEventListener('input', function(e) {
          circles[e.target.id].setRadius(e.data);
        });
        popup.appendChild(spinner);
        circle = L.circle(marker.getLatLng(), 100, {
            color: colors[name],
            fillcolor: colors[name],
            fillopacity: 0.5,

        }).bindPopup(popup).addTo(map);

        marker.on('drag', (e) => {
            circles[names[e.target.options.title]].setLatLng(e.latlng);
        });
        circles[name] = circle;
    }
}
~~~

As is usual we check if there is already a circle with this name before we create one. Then we generate the 
popup that allows the user to change the radius of the circle. This is a basic HTML `div` with a spinner (or 
`number` as HTML calls them for some reason), we can set the minimum, maximum and step for this in the HTML as 
per normal. The trick then to add a function to the `input` event that is fired when ever the user clicks the 
spinner (or uses their up/down arrows on it). The remaining issue is to make sure that the right circle gets 
updated when the input changes, to do this I set the id of the spinner to the same name that keys the 
dictionary of circles (these keys match the markers too). Then we can simply use the `setRadius` method of the 
`CircleMarker` that we are about to create. Then we create the `CircleMaker` and attach the popup to it and 
add it to the map. Finally, when we drag the matching marker we want to move we need to change the centre of 
the circle. This needs a function for the `drag` event to do this, it's slightly more complex to look up the 
required circle from a marker due to makers having nice long titles so there's a double lookup, if I had 
millions of markers this might be a problem but with 3 it's fine.

And that's all there is too it, that's not to say I like JavaScript or web development but in the end its not 
too hard!
