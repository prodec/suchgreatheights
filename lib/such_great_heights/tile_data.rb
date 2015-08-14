module SuchGreatHeights
  # Keeps data identifying a loaded tile, such as it anchoring
  # corner, if it's of SRTM1 or SRTM3 type and the altitude data.
  #
  # @attr filename [String] the filename
  # @attr latitude [Float] the anchoring latitude
  # @attr longitude [Float] the anchoring longitude
  # @attr square_side [Fixnum] one of SRTM1_SIDE or SRTM3_SIDE
  # @attr data [Array<Array<Fixnum>>] the altitude data
  class TileData
    # @param filename [String] the filename
    # @param latitude [Float] the anchoring latitude
    # @param longitude [Float] the anchoring longitude
    # @param square_side [Fixnum] one of SRTM1_SIDE or SRTM3_SIDE
    # @param data [Array<Array<Fixnum>>] the altitude data
    def initialize(filename, latitude, longitude, square_side, data)
      @filename    = filename
      @latitude    = latitude
      @longitude   = longitude
      @square_side = square_side
      @data        = data
    end

    attr_reader :filename, :latitude, :longitude, :square_side, :data
  end
end
