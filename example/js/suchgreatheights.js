var connection = new WebSocket("ws://suchgreatheights.sigvia.com");
var lineString = [
  [-44.231, -21.231],
  [-43.231, -22.231]
];

var map, heartbeat;

connection.onopen = function() {
  hearbeat = setInterval(sendHeartbeat, 15000);
};

connection.onclose = function() {
  clearInterval(heartbeat);
};

connection.onmessage = dispatch;

function sendHeartbeat() {
  connection.send(JSON.stringify({
    command: "ping",
    sent_at: +new Date
  }));
}

function initialize() {
  var mapOptions = {
    center: { lat: lineString[0][1], lng: lineString[0][0] },
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
                            mapOptions);
  google.maps.event.addListener(map, "mousemove", requestAltitude());

  drawRoute(map);
}

function drawRoute(map) {
  var path = new google.maps.Polyline({
    path: lineString.map(function(p) {
      return new google.maps.LatLng(p[1], p[0]);
    }),
    //geodesic: true,
    strokeColor: "#FF0000",
    strokeWeight: 3
  });

  path.setMap(map);
}

function dispatch(resp) {
  var result = JSON.parse(resp.data);

  if (result.response == "route_profile") {
    displayRoute(result);
  } else if (result.response == "point_altitude") {
    displayAltitude(result);
  }
}

function requestAltitude() {
  var lastSent;

  return function(me) {
    var latLng = me.latLng,
        now = new Date;

    if (!lastSent || (now - lastSent) > 40) {
      connection.send(JSON.stringify({
        command: "point_altitude",
        payload: {
          lat: latLng.lat(),
          lng: latLng.lng()
        },
        sent_at: +new Date
      }));

      lastSent = now;
    }
  };
}

function displayAltitude(result) {
  document.getElementById("current-altitude").innerText = result.data.altitude;
}

function displayRoute(resp) {
  showRouteHeights(resp);
  drawRouteProfile(resp);
}

function showRouteHeights(resp) {
  var tbody = document.getElementById("profile-results");
  tbody.innerHTML = "";

  resp.data.profile.forEach(function(p) {
    var tr = document.createElement("tr");
    var x  = document.createElement("td"),
        y  = document.createElement("td"),
        z  = document.createElement("td");

    x.innerText = p[0];
    y.innerText = p[1];
    z.innerText = p[2];

    tr.appendChild(x);
    tr.appendChild(y);
    tr.appendChild(z);

    tbody.appendChild(tr);
  });
}

function drawRouteProfile(resp) {
  var path = new google.maps.Polyline({
    path: resp.data.profile.map(function(p) {
      return new google.maps.LatLng(p[1], p[0]);
    }),
    geodesic: true,
    strokeColor: "#0000FF",
    strokeWeight: 3
  });

  path.setMap(map);
}

google.maps.event.addDomListener(window, 'load', initialize);
document.getElementById("send-route").addEventListener("click", function() {
  connection.send(JSON.stringify({
    command: "route_profile",
    payload: {
      route: {
        type: "LineString",
        coordinates: lineString
      }
    },
    sent_at: +new Date
  }));
});
