module SuchGreatHeights
  module TileLoader
    # Loads SrtmTiles from disk, defaulting to a NullTile if it
    # doesn't exist in disk or if the data is malformed.
    #
    # @return [SrtmTile, NullTile]
    def self.load(filename)
      return NullTile.instance if !File.exist?(filename)

      SrtmTile.new(filename)
    rescue WrongDimensionsError
      NullTile.instance
    end
  end
end
