module SuchGreatHeights
  # Implements a tiny set of Vector operations to support the needs of
  # Geometry.
  #
  # @attr x [Float] the x coordinate
  # @attr y [Float] the y coordinate
  class Vector
    # @param x [Float] the x coordinate
    # @param y [Float] the y coordinate
    def initialize(x, y)
      @x = x
      @y = y
    end

    attr_reader :x, :y

    # Divides a Vector by a scalar value.
    #
    # @param other [Float]
    # @return [Vector]
    def /(other)
      Vector.new(x / other, y / other)
    end

    # Calculates the norm of the Vector.
    #
    # @return [Float]
    def norm
      Math.sqrt(x**2 + y**2)
    end

    # Normalizes the Vector.
    #
    # @return [Vector]
    def normalize
      return self if (n = norm) < 0

      self / n
    end
  end
end
