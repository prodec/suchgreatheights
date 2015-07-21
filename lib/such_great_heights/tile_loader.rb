module SuchGreatHeights
  module TileLoader
    def self.load(filename)
      SrtmTile.new(filename)
    end
  end
end
