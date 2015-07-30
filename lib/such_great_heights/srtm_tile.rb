require "forwardable"

module SuchGreatHeights
  Position = Struct.new(:x, :y, :z)

  class SrtmTile
    extend Forwardable

    def initialize(zipfile, data_loader: TileDataLoader)
      @tile_data = data_loader.load_tile(zipfile)
    end

    def_delegators :@tile_data, :data, :latitude, :longitude, :filename, :square_side

    def altitude_for(lon, lat)
      return NO_DATA if !lon || !lat

      row, col = row_and_column_for(lon, lat)

      fail OutOfBoundsError if row < 0 || col < 0

      data[row][col]
    end

    def positions
      data.flat_map.with_index do |row, i|
        row.map.with_index do |alt, j|
          lon, lat = lon_lat_from_cell(i, j)

          Position.new(lon, lat, alt)
        end
      end
    end

    def to_s
      "<<SRTM>>"
    end

    def inspect
      "<<SRTM>>"
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
