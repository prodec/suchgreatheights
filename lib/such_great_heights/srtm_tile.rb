module SuchGreatHeights
  Position = Struct.new(:x, :y, :z)

  class SrtmTile
    include Enumerable

    ARCSECOND  = (1 / 3600.0) # in degrees

    def initialize(zipfile, tile_loader: TileLoader)
      tile_data = tile_loader.load_tile(zipfile)
      @filename = tile_data.filename
      @side     = tile_data.square_side
      @data     = tile_data.data
      @latitude = tile_data.latitude
      @longitude = tile_data.longitude
    end

    attr_reader :data, :latitude, :longitude, :side, :filename, :cell_size

    def altitude_for(lon, lat)
      row, col = row_and_column_for(lon, lat)

      fail OutOfBoundsError if row < 0 || col < 0

      data[row][col]
    end

    def each
      data.each.with_index do |row, i|
        row.each.with_index do |alt, j|
          lon, lat = lon_lat_from_cell(i, j)

          yield Position.new(lon, lat, alt)
        end
      end
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

    def to_s
      "<<SRTM>>"
    end

    def inspect
      "<<SRTM>>"
    end
  end
end
