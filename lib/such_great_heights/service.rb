require "celluloid"

module SuchGreatHeights
  class Service
    include Celluloid

    def initialize(tile_cache: Celluloid::Actor[:tile_cache])
      @tile_cache = tile_cache
    end

    attr_reader :tile_cache
    private :tile_cache

    def altitude_for(lon, lat)
      AltitudeResponse.new(altitude(lon, lat))
    end

    def route_profile(route)
      coordinates = Geometry.interpolate_route(as_vertices(route.fetch("coordinates")))

      ProfileResponse.new(Array(coordinates).map { |p|
                            Point.new(p.x, p.y, altitude(p.x, p.y))
                          })
    end

    private

    def altitude(lon, lat)
      tile(lon, lat).altitude_for(lon, lat)
    end

    def tile(lon, lat)
      tile_cache.fetch(lon, lat)
    end

    def as_vertices(coords)
      coords.map { |c| Vector.new(*c) }
    end
  end
end
