module SuchGreatHeights
  Position = Struct.new(:x, :y, :z)

  class SrtmTile
    def initialize(zipfile, data_loader: TileDataLoader)
      tile_data = data_loader.load_tile(zipfile)
      @filename = tile_data.filename
      @side     = tile_data.square_side
      @data     = tile_data.data
      @latitude = tile_data.latitude
      @longitude = tile_data.longitude
    end

    attr_reader :data, :latitude, :longitude, :side, :filename, :cell_size

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
      [((latitude + 1 - lat) * (side - 1).to_f).floor,
       ((lon - longitude) * (side - 1).to_f).floor]
    end

    def lon_lat_from_cell(r, c)
      dec_part_lat = (r * ARCSECOND * cell_size)
      dec_part_lon = (c * ARCSECOND * cell_size)

      [longitude + dec_part_lon, (latitude + 1) - dec_part_lat]
    end

    def cell_size
      side == SRTM3_SIDE ? 3 : 1
    end
  end
end
