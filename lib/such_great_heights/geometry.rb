require "rgeo"

module SuchGreatHeights
  module Geometry
    # Determines the length of a LineString.
    #
    # @param coords [Array<Vector>] a set of pairs of coordinates
    #
    # @return [Float] length in kilometers
    def line_length(coords)
      coords.each_cons(2).inject(0) do |dist, (a, b)|
        dist + distance(a, b)
      end
    end

    # Determines the distance between two points.
    #
    # @param p0 [Vector]
    # @param p1 [Vector]
    #
    # @return [Float] distance in kilometers
    def distance(p0, p1)
      a = factory.point(p0.x, p0.y)
      b = factory.point(p1.x, p1.y)

      a.distance(b) / 1000.0
    end

    # Adds points to a LineString to improve a Profile's resolution.
    #
    # @param coords [Array<Vector>] a set of pairs of coordinates
    # @param max_dist [Float] the maximum distance between points (defaults to 100km)
    #
    # @return [Array<Vector>] a new route
    def interpolate_route(coords, max_dist = 100)
      return coords if max_dist <= 0

      length  = line_length(coords)
      min_res = length / max_dist

      coords.each_cons(2).inject([]) do |route, (a, b)|
        segment = add_extra_points(a, b, min_res)
        route + segment
      end
    end

    # Adds extra points to a LineString segment, following the desired
    # resolution.
    #
    # @param p0 [Vector]
    # @param p1 [Vector]
    # @param min_res [Float] the minimum resolution to consider
    #
    # @return [Array<Vector>] a new LineString segment
    def add_extra_points(p0, p1, min_res)
      n  = points_to_add_between(p0, p1, min_res)
      dir = direction(p0, p1)

      (0..n).map do |offset|
        offset_point(p0, dir, min_res * offset)
      end + [p1]
    end

    def direction(p0, p1)
      wmp0 = point_to_webmercator(p0)
      wmp1 = point_to_webmercator(p1)

      Vector.new(wmp1.x - wmp0.x, wmp1.y - wmp0.y)
        .normalize
    end

    def point_to_webmercator(point)
      factory.point(point.x, point.y).projection
    end

    def offset_point(point, dir, offset_kms)
      projected = offset_as_mercator(point, dir, offset_kms)
      factory.unproject(projected)
    end

    def offset_as_mercator(point, dir, offset_kms)
      wmp = point_to_webmercator(point)
      wmp.factory.point(
        wmp.x + (dir.x * offset_kms * 1000),
        wmp.y + (dir.y * offset_kms * 1000)
      )
    end

    # Determines how many extra points should be added in a LineString
    # segment.
    #
    # @param p0 [Vector]
    # @param p1 [Vector]
    # @param min_res [Float] the minimum resolution to consider
    #
    # @return [Fixnum] the number of points to add
    def points_to_add_between(p0, p1, min_res)
      dist = distance(p0, p1)
      [((dist / min_res).floor - 1).to_i, 0].max
    end

    def factory
      @factory ||= RGeo::Geographic.simple_mercator_factory
    end

    module_function :line_length, :distance, :interpolate_route, :factory,
                    :add_extra_points, :points_to_add_between, :direction,
                    :offset_point, :point_to_webmercator, :offset_as_mercator
  end
end
