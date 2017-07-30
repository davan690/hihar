import { Template } from 'meteor/templating';
import { ReactiveVar } from 'meteor/reactive-var';
import { Mongo } from 'meteor/mongo';

import './main.html';


Posts = new Mongo.Collection("posts");
Posts.insert({title: "title-1"});
Posts.insert({title: "title-2"});
console.log(Posts.find().count());

Router.route('/', function () {
  this.render('main');
});

Router.route('/ack');



Template.main.onCreated(function mainOnCreated() {
   this.counter = new ReactiveVar(0);
   this.message = new ReactiveVar("");
   this.map;
});

Template.main.onRendered(function mainOnRendered()
{
   if (Meteor.isClient)
   {
      L.Icon.Default.imagePath = 'packages/bevanhunt_leaflet/images';

      var bgn = [-35.3310416, 149.1256633];
      var map = Template.instance().map;
      var opt = { doubleClickZoom: true,
                  zoomControl: false,
                  touchZoom: true,
                  scrollWheelZoom: true,
                  maxZoom: 20 }
      map = L.map('map', opt)
         .setView(bgn, 13);

      L.tileLayer.provider('Thunderforest.Transport').addTo(map);

      L.control.zoom().setPosition('bottomright').addTo(map);

      var popup = L.popup();

      map.on('click', function(e){
         popup
             .setLatLng(e.latlng)
             .setContent("This location is:<br>" + e.latlng.toString())
             .openOn(map);
      });

      var circle = L.circle([-35.3310416, 149.1256633], 500, {
         color: 'red',
         fillColor: '#f03',
         fillOpacity: 0.5
      });
      circle.addTo(map);
      circle.bindPopup("I am a circle.");

      Template.instance().message.set("Map Loaded");
      Template.instance().map = map;
   }

   Tracker.afterFlush(function(){
      this.$(".collapsible").collapsible({
        accordion: false
      });
    }.bind(this));

});

Template.main.helpers({
  counter() {
    return Template.instance().counter.get();
  },
  message() {
    return Template.instance().message.get();
  },
});

Template.main.events({
  "click [data-action='quack']"(event, instance) {
    instance.message.set("Trying to get location...");

    if (navigator.geolocation)
    { 
      navigator.geolocation.getCurrentPosition(
        function(pos)
        {
          var msg = "Latitude: " + pos.coords.latitude + 
                    " Longitude: " + pos.coords.longitude;
          instance.message.set(pos.coords);
        });
    }
    else
    {
      instance.message.set("Error. Geolocation not available");
    }

    var opt = { setView: true, maxZoom: 16 };
    instance.map.locate(opt);
    instance.map.on("locationfound", function(e){
       var marker = L.marker(e.latlng);
       marker.addTo(instance.map);
       marker.bindPopup("This is your location").openPopup();
       instance.message.set(e.latlng);
    });
  },
  "click [data-action='takePicture']": function(e, instance) {
    e.preventDefault();
    instance.message.set("taking picture");
    var cameraOptions = {
        width: 640,
        height: 480
    };
    MeteorCamera.getPicture(cameraOptions, function (error, data) {
       if (!error) {
          instance.$('.photo').attr('src', data);
          instance.$('.ack-photo').attr('src', data);
          instance.message.set("picture taken!");
       }
    });
  },
  "click [data-action='submit']": function(e, instance) {
    var val = instance.$('.capture').value;
    instance.message.set(val);
  },

});



Template.ack.onCreated(function() {
  this.ack_data = new ReactiveVar("(Empty)");
});

Template.ack.helpers({
  ack_data() {
    return Template.instance().ack_data.get();
  },
});


