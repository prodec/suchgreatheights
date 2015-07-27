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
      coordinates = Geometry.interpolate_route(route.fetch("coordinates"))

      ProfileResponse.new(Array(coordinates).map { |p|
                            Point.new(p[0], p[1], altitude(p[0], p[1]))
                          })
    end

    private

    def altitude(lon, lat)
      tile(lon, lat).altitude_for(lon, lat)
    end

    def tile(lon, lat)
      tile_cache.fetch(lon, lat)
    end
  end
end
