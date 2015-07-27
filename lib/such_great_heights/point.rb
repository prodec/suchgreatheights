module SuchGreatHeights
  Point = Struct.new(:x, :y, :z) do
    def to_json(*)
      [x, y, z].to_json
    end
  end
end
