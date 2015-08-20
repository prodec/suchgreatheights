# such_great_heights

[![Code Climate](https://codeclimate.com/github/prodec/suchgreatheights/badges/gpa.svg)](https://codeclimate.com/github/prodec/suchgreatheights)

This service provides fetching the altitudes for geographic pairs of coordinates using NASA's topography data ([read more about it][srtm]). It can serve both SRTM1 and SRTM3 data, and it's ready to be used both via HTTP and WebSockets.

There's only two endpoints:

- `point_altitude(lng, lat)`: returns the altitude for a longitude and latitude pair
- `route_profile(route)`: receives a route as a GeoJSON LineString and returns an altitude profile

## Running it

The first thing you should do is download the data you need. There's many places on the Internet with SRTM tiles &mdash; such\_great\_heights was developed using those available here: [https://dds.cr.usgs.gov/srtm/](https://dds.cr.usgs.gov/srtm/). Copy everything you need to make available to a flat directory and create a `config/suchgreatheights.yml`, like this:

    $ cd config
    $ cp suchgreatheights.yml.sample suchgreatheights.yml

Open your favorite editor and change the `tile_set_path` key to point to wherever your data is located. Ignore the other configuration options for now. You can now run it with the following steps:

    $ bundle install
    $ bin/server

The service will be bound to port 7331, and will be ready for HTTP and WebSocket clients.

## Configuring it

There are three configuration options:

  - `tile_set_path`: the path to the directory with the tiles (in .hgt.zip format)
  - `tile_duration`: how long to hold the tile in memory after it's been last accessed (defaults to 6h. See more in [Architecture](#architecture))
  - `log_path`: the log file path (defaults to `log/suchgreatheights.log`)

## Using it

### HTTP

#### Fetching the altitude of a single point
  - **[GET]**: `/altitude?lat=<float>&lng=<float>` - returns a JSON response with the structure below.

```
{ altitude: <float> }
```

#### Fetching a route profile
  - **[GET]**: `/profile?route=<json array>` - returns a JSON response with the structure below. `profile` is an Array of Arrays, each with three values (longitude, latitude and altitude/elevation).

```
{ profile: [[<float>, <float>, <float>]...]}
```

  - **[POST]**: `/profile`, payload: LineString GeoJSON - retorna JSON com a seguinte estrutura

```
{ profile: [[<float>, <float>, <float>]...]}
```

#### Examples

  - Fetching the altitude of a point (`GET`)

```
$ curl -XGET http://localhost:7331/altitude\?lng\=-42.123123\&lat\=-21.98888
{"altitude":287}
```

  - Fetching a route profile (`GET`)

```
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],...]}
```

  - Fetching a route profile (`POST`)

```
$ curl -XPOST -d '{"type": "LineString", "coordinates": [[-43.114,-22.321],[-43.124,-22.331]] }' http://localhost:7331/profile
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],...]}
```

### WebSocket

  - Fetching the altitude of a point:
    - Payload: `{ "command": "point_altitude", "sent_at": <timestamp>, "payload": { "lat": <float>, "lng": <float> } }`
    - Response: `{ "response": "route_profile", "client_sent_at": <timestamp>, "processed_at": <timestamp>, "data": { "altitude": <number> } }`
  - Fetching a route profile
    - Payload: `{ "command": "route_profile", "sent_at": <timestamp>, "payload": { "route": <LineString GeoJSON> } }`
    - Response: `{ "response": "route_profile", "client_sent_at": <timestamp>, "processed_at": <timestamp>, "data": { "profile": <Ver HTTP> } }`
  - *Heartbeat*
    - Payload: `{ "command": "ping", "sent_at": <timestamp> }`
    - Response: `{ "response": "ping", "client_sent_at": <timestamp>, "processed_at": <timestamp> }`

WebSocket users should take care of sending a heartbeat every few seconds if they're running behind a proxy. [nginx][nginx], for instance, is very aggressive with idle connections and will kill them after about a minute.

## Putting it in production

There's an Ansible Playbook ready to put it in production in an Ubuntu Server, behind an nginx instance. Tweak it to your needs.

## Architecture

The project was conceived to have as few dependencies as possible, and the lowest latency as well. Its first client was an internal service used to plan drone flights that had as  requirements getting elevation updates on mouse move and evaluating of flight plans in relation to the elevation data (i.e. "will I hit something obvious?").

Loading tiles takes about 175ms, and fetching altitudes about 5.8ns (it's basically an array access). There was an attempt at loading every single SRTM tile to memory, which proved prohibitive, so there were two choices (without accruing dependencies and/or changing latency requirements):

- Confine ourselves to know flight areas and loading only those tiles;
- Load tiles on demand.

A choice was made to go with the latter. Tiles are loaded on demand and kept in memory only if they're accessed. If they're not, they get a grace period before being discarded (controlled by the `tile_duration` configuration option and defaulting to 6h). As of the writing of this paragraph (august 2015), it's working fine.

### Celluloid

Almost everything is an actor. The key structures &mdash; Service and TileCache &mdash; are behind a Supervision Group that takes care of restarting them if anything goes wrong. WebSocket Clients (also actors) will have to reconnect if anything happens (they just crash and burn if Service dies).


[srtm]: http://www2.jpl.nasa.gov/srtm/
[nginx]: http://nginx.org/
