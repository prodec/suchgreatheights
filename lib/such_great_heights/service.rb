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
      altitude = tile(lon, lat).altitude_for(lon, lat)

      AltitudeResponse.new(altitude)
    end

    def route_profile(route)
      coordinates = route.fetch("coordinates")

      ProfileResponse.new(Array(coordinates).map { |p| altitude_for(p[0], p[1]) })
    end

    private

    def tile(lon, lat)
      tile_cache.fetch(lon, lat)
    end
  end
end
