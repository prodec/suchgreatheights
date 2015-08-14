require "forwardable"

module SuchGreatHeights
  # Represents a well-formed SRTM data tile, either in SRTM1 or SRTM3
  # format.
  class SrtmTile
    extend Forwardable

    # @param zipfile_path [String] The path to a zipfile with SRTM
    #   data (with the .hgt.zip extension)
    def initialize(zipfile_path, data_loader: TileDataLoader)
      @tile_data = data_loader.load_tile(zipfile_path)
    end

    # @!method data
    # @!method latitude
    # @!method longitude
    # @!method filename
    # @!method square_side
    def_delegators :@tile_data, :data, :latitude, :longitude, :filename, :square_side

    # Fetches an altitude for a given coordinate pair.
    #
    # @param lon [Float] a longitude
    # @param lat [Float] a latitude
    # @raise [OutOfBoundsError] if the pair is not in the tile
    # @return [Fixnum] an altitude (in meters)
    def altitude_for(lon, lat)
      return NO_DATA if !lon || !lat

      row, col = row_and_column_for(lon, lat)

      fail OutOfBoundsError if row < 0 || col < 0

      data[row][col]
    end

    private

    def row_and_column_for(lon, lat)
      [((latitude + 1 - lat) * (square_side - 1).to_f).floor,
       ((lon - longitude) * (square_side - 1).to_f).floor]
    end

    def lon_lat_from_cell(r, c)
      dec_part_lat = (r * ARCSECOND * cell_size)
      dec_part_lon = (c * ARCSECOND * cell_size)

      [longitude + dec_part_lon, (latitude + 1) - dec_part_lat]
    end

    def cell_size
      square_side == SRTM3_SIDE ? 3 : 1
    end
  end
end
