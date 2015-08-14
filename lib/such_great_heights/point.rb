module SuchGreatHeights
  # Takes care of serializing 3d points to JSON.
  Point = Struct.new(:x, :y, :z) do
    def to_json(*)
      [x, y, z].to_json
    end
  end
end
