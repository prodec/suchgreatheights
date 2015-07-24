module SuchGreatHeights
  module TileLoader
    def self.load(filename)
      return NullTile.instance if !File.exist?(filename)

      SrtmTile.new(filename)
    end
  end
end
