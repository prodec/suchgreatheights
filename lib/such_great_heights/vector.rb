module SuchGreatHeights
  class Vector
    def initialize(x, y)
      @x = x
      @y = y
    end

    attr_reader :x, :y

    def /(other)
      Vector.new(x / other, y / other)
    end

    def norm
      Math.sqrt(x**2 + y**2)
    end

    def normalize
      return self if (n = norm) < 0

      self / n
    end
  end
end
