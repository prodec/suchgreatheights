require "celluloid"

module SuchGreatHeights
  class Service
    include Celluloid

    def initialize(tile_set, tile_duration, tile_cache: TileCache)
      @tile_cache = tile_cache.new_link(tile_set, tile_duration)
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
