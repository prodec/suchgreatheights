require "rgeo"

module SuchGreatHeights
  module Geometry
    # Determines the length of a LineString.
    #
    # @param coords [Array<Pair<Float,Float>>] a set of pairs of coordinates
    #
    # @return [Float] length in kilometers
    def line_length(coords)
      coords.each_cons(2).inject(0) { |dist, (a, b)|
        dist + distance(*a, *b)
      }
    end

    # Determines the distance between two points.
    #
    # @param x0 [Float]
    # @param y0 [Float]
    # @param x1 [Float]
    # @param y1 [Float]
    #
    # @return [Float] distance in kilometers
    def distance(x0, y0, x1, y1)
      factory.point(x0, y0).distance(factory.point(x1, y1)) / 1000.0
    end

    # Adds points to a LineString to improve a Profile's resolution.
    #
    # @param coords [Array<Pair<Float,Float>>] a set of pairs of coordinates
    # @param max_dist [Float] the maximum distance between points (defaults to 100km)
    #
    # @return [Array<Pair<Float,Float>>] a new route
    def interpolate_route(coords, max_dist = 100)
      return coords if max_dist <= 0

      length  = line_length(coords)
      min_res = length / max_dist

      coords.each_cons(2).inject([]) { |route, (a, b)|
        segment = add_extra_points(a, b, min_res)
        route + segment
      }
    end

    # Adds extra points to a LineString segment, following the desired
    # resolution.
    #
    # @param p0 [Pair<Float,Float>]
    # @param p1 [Pair<Float,Float>]
    # @param min_res [Float] the minimum resolution to consider
    #
    # @return [Array<Pair<Float,Float>>] a new LineString segment
    def add_extra_points(p0, p1, min_res)
      n = points_to_add_between(p0, p1, min_res)

      between = (0..n).map { |i|
        [p0[0] + ((p1[0] - p0[0]) / (n + 1) * (i + 1)),
         p0[1] + ((p1[1] - p0[1]) / (n + 1) * (i + 1))]
      }

      [p0, *between, p1]
    end

    # Determines how many extra points should be added in a LineString
    # segment.
    #
    # @param p0 [Pair<Float,Float>]
    # @param p1 [Pair<Float,Float>]
    # @param min_res [Float] the minimum resolution to consider
    #
    # @return [Fixnum] the number of points to add
    def points_to_add_between(p0, p1, min_res)
      dist = distance(*p0, *p1)
      [((dist / min_res).floor - 1).to_i, 0].max
    end

    def factory
      @factory ||= RGeo::Geographic.simple_mercator_factory
    end

    module_function :line_length, :distance, :interpolate_route, :factory,
                    :add_extra_points, :points_to_add_between
  end
end
