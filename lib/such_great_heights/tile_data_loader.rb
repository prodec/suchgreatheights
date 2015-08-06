require "zip"

module SuchGreatHeights
  class TileDataLoader
    PACKING    = "s>"
    CHUNK_SIZE = [1].pack(PACKING).size

    include SrtmConversions

    def initialize(zipfile)
      @zipfile  = zipfile
      @filename = File.basename(zipfile.sub(".zip", ""))
    end

    attr_reader :filename, :tempfile, :square_side, :zipfile
    private :filename, :tempfile, :square_side, :zipfile

    def load
      with_unzipped_file do |uzf|
        square_side = Math.sqrt(uzf.length / 2).to_i

        fail WrongDimensionsError if square_side != SRTM1_SIDE && square_side != SRTM3_SIDE

        lon, lat = tile_to_lon_lat(filename)
        TileData.new(filename, lat, lon, square_side, read_data(uzf, square_side))
      end
    end

    def self.load_tile(zipfile)
      new(zipfile).load
    end

    private

    def with_unzipped_file
      Zip::File.open(zipfile) do |zip|
        entry = if zip.find_entry(filename)
                  filename
                else
                  filename.downcase
                end

        yield zip.read(entry)
      end
    end

    def read_data(contents, square_side)
      square_side.times.map do |i|
        offset = CHUNK_SIZE * square_side
        buffer = contents[i * offset, offset]
        buffer.unpack("#{PACKING}*")
      end
    end
  end
end
