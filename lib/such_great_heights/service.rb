require "celluloid"

module SuchGreatHeights
  # A Service takes care of turning beautiful requests for either the
  # height of a point or the profile of a route and turning it into
  # magical responses, full of splendor.
  class Service
    include Celluloid
    include Celluloid::Notifications

    def initialize(tile_cache: Celluloid::Actor[:tile_cache])
      @tile_cache = tile_cache
    end

    attr_reader :tile_cache
    private :tile_cache

    # Finds the altitude for a given pair of geographic coordinates.
    #
    # @param lon [Float] a longitude
    # @param lat [Float] a latitude
    # @return [AltitudeResponse] a response
    def altitude_for(lon, lat)
      AltitudeResponse.new(altitude(lon, lat))
    end

    # Builds the profile for a given route, interpolating points along
    # the way in order to avoid abrupt changes in height. The
    # resolution of interpolation is determined by the max_dist
    # parameter (i.e. the higher it is, the more points you
    # potentially have).
    #
    # @param route [Hash] a GeoJSON LineString
    # @param dist_factor [Float] the distance factor to use when
    #   interpolating (the higher it is, the more points you get)
    # @return [ProfileResponse] a response
    def route_profile(route, dist_factor = 100.0)
      coordinates = Geometry.interpolate_route(as_vertices(route.fetch("coordinates")),
                                               dist_factor)

      ProfileResponse.new(Array(coordinates).map do |p|
                            Point.new(p.x, p.y, altitude(p.x, p.y))
                          end)
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
