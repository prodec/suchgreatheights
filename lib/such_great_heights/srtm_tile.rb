module SuchGreatHeights
  Position = Struct.new(:x, :y, :z)

  class SrtmTile
    include Enumerable

    ARCSECOND  = (1 / 3600.0) # in degrees
    SRTM1_SIDE = 3601
    SRTM3_SIDE = 1201

    def initialize(filename)
      @filename   = filename
      @side       = Math.sqrt(File.size(filename) / 2).to_i

      fail "Invalid tile size" if side != SRTM1_SIDE && side != SRTM3_SIDE

      @data = read_data
      @longitude, @latitude = tile_coordinates
    end

    attr_reader :data, :latitude, :longitude, :side, :filename, :cell_size

    def altitude(lon, lat)
      row, col = row_and_column_for(lon, lat)

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

    def tile_coordinates
      /(?<ns>[NS])(?<lat>\d+)(?<ew>[EW])(?<lon>\d+)\.hgt/ =~ filename

      [ew == "E" ? lon.to_i : lon.to_i * -1,
       ns == "N" ? lat.to_i : lat.to_i * -1]
    end

    def row_and_column_for(lon, lat)
      [((latitude + 1 - lat) * (side - 1).to_f).floor,
       ((lon - longitude) * (side - 1).to_f).floor]
    end

    def read_data
      chunk_size = [1].pack("n").size

      File.open(filename) do |f|
        buffer = ""

        side.times.map {
          f.read(chunk_size * side, buffer)
          buffer.unpack("n*")
        }.compact
      end
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
