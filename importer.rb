class Position < Struct.new(:x, :y, :z); end

class SrtmTile
  include Enumerable

  ARCSECOND  = (1 / 3600.0) # in degrees
  SRTM1_SIDE = 3601
  SRTM3_SIDE = 1201

  def initialize(filename)
    @filename   = filename
    @side       = Math.sqrt(File.size(filename) / 2).to_i
    raise "WAT" if side != SRTM1_SIDE && side != SRTM3_SIDE

    @longitude, @latitude = tile_coordinates
    @cell_size  = side == 1201 ? 3 : 1
    @chunk_size = [1].pack("n").size
    @data       = read_data
  end

  attr_reader :data, :latitude, :longitude, :side, :chunk_size, :filename, :cell_size

  def altitude(lon, lat)
    row, col = row_and_column_for(lon, lat)

    data[row][col]
  end

  def each
    data.each.with_index do |row, i|
      row.each.with_index do |alt, j|
        dec_part_lat = (i * ARCSECOND * cell_size)
        dec_part_lon = (j * ARCSECOND * cell_size)
        lon = longitude + dec_part_lon
        lat = (latitude + 1) - dec_part_lat

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
    side = data.first.size

    [((latitude + 1 - lat) * (side - 1).to_f).floor,
     ((lon - longitude) * (side - 1).to_f).floor]
  end

  def read_data
    File.open(filename) do |f|
      buffer = ""

      side.times.map do
        f.read(chunk_size * side, buffer)
        buffer.unpack("n*")
      end.compact
    end
  end

  def to_s
    "<<SRTM>>"
  end

  def inspect
    "<<SRTM>>"
  end
end

def load_tile
  SrtmTile.new(File.expand_path("~/Desktop/N00W050.hgt"))
end
