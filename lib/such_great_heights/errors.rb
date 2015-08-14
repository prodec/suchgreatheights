module SuchGreatHeights
  # To be thrown when an SRTM file is not of proper dimensions.
  class WrongDimensionsError < StandardError; end
  # To be thrown when a pair of coordinates does not belong to a Tile.
  class OutOfBoundsError < StandardError; end
end
