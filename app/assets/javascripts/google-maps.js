//  https://maps.googleapis.com/maps/api/geocode/json?address=420+Lexington+Ave%2CNew+York%2CNY&sensor=false&region=us
// "location" : {
//     "lat" : 40.7524430,
//     "lng" : -73.97545599999999

//  eeekkk globals 
var globalmap;
var markers = [];

// function initialize() {
//     var myOptions = {
//         zoom: 13,
//         center: new google.maps.LatLng(40.7524430, -73.97545599999999),
//         mapTypeId: google.maps.MapTypeId.ROADMAP
//     }
//     var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
//     globalmap = map;
// }

// function AutoCenter() {
//     //  Create a new viewpoint bound
//     var bounds = new google.maps.LatLngBounds();
//     //  Go through each...
//     $.each(markers, function (index, marker) {
//         bounds.extend(marker.position);
//     });
//     //  Fit these bounds to the map
//     globalmap.fitBounds(bounds);
// }

function placePinsOnMap() {
  // iterate thru the dom class "address"
  // if there is lat/lng then create pin overlay
  // else call function geocodeAnAddress()
    console.log("start placePinsOnMap");
    
    var locations = []
    // $(".patient_list_item").each(function(index) {
    //     //console.log(index + ":" + $(this).attr("data-lat"));
    //     var name = $(this).html();
    //     var lat = $(this).attr('data-lat');
    //     var lng = $(this).attr('data-lng');
    //     console.log(index + ': ' + lat + " / " + lng );
    //     //locations.push(new google.maps.LatLng(lat, lng));
    //     //console.log("name: " + name);
    //     locations.push([name, lat, lng, index]);
    // })  

    var name = "dogwalk photo location";
    var lat = $("#photo-latitude").val();
    var lng = $("#photo-longitude").val();
    console.log("1" + ': ' + lat + " / " + lng );
    locations.push([name, lat, lng, 1]);

    // var map = new google.maps.Map(document.getElementById('map_canvas'), {
    //   zoom: 8,
    //   center: new google.maps.LatLng(40.7524430, -73.97545599999999),
    //   mapTypeId: google.maps.MapTypeId.ROADMAP
    // });
    var map = new google.maps.Map(document.getElementById('map_canvas'), {
      zoom: 16,
      center: new google.maps.LatLng(lat, lng),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    globalmap = map;
    var infowindow = new google.maps.InfoWindow();

    var marker, i;

    console.log("locations.length = " + locations.length);

    for (i = 0; i < locations.length; i++) {  
        marker = new google.maps.Marker({
            position: new google.maps.LatLng(locations[i][1], locations[i][2]),
            map: map
        });

        markers.push(marker);

        google.maps.event.addListener(marker, 'click', (function(marker, i) {
            return function() {
                infowindow.setContent(locations[i][0]);
                infowindow.open(map, marker);
            }
        })(marker, i));
    }
    //AutoCenter();
}

function loadScript() {
  var script = document.createElement("script");
  script.type = "text/javascript";
  script.src = "http://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&sensor=TRUE&callback=initialize";
  document.body.appendChild(script);
}

$(function(){
    
    // if there is a map on the page, initialize it 
    if ($("#map_canvas").length) {
        // initialize();
        placePinsOnMap();
    }



});
