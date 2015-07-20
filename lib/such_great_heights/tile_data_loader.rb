require "zip"

module SuchGreatHeights
  class TileDataLoader
    PACKING    = "s>"
    CHUNK_SIZE = [1].pack(PACKING).size

    include SrtmConversions

    def initialize(zipfile, temp_dir)
      @zipfile  = zipfile
      @filename = File.basename(zipfile.sub(".zip", ""))
      @tempfile = SecureRandom.hex(16) + "-" + filename
      @temp_dir = temp_dir
    end

    attr_reader :filename, :tempfile, :temp_dir, :square_side, :zipfile
    private :filename, :tempfile, :temp_dir, :square_side, :zipfile

    def load
      with_unzipped_file do |uzf|
        square_side = Math.sqrt(File.size(uzf) / 2).to_i

        fail WrongDimensionsError if square_side != SRTM1_SIDE && square_side != SRTM3_SIDE

        lon, lat = tile_to_lon_lat(filename)
        TileData.new(filename, lat, lon, square_side, read_data(square_side))
      end
    end

    def self.load_tile(zipfile, temp_dir = Dir.tmpdir)
      new(zipfile, temp_dir).load
    end

    private

    def with_unzipped_file
      Zip::File.open(zipfile) do |zip|
        zip.extract(filename, unzipped_file)

        yield unzipped_file
      end
    ensure
      File.unlink(unzipped_file) if File.exist?(unzipped_file)
    end

    def unzipped_file
      File.join(temp_dir, tempfile)
    end

    def read_data(square_side)
      File.open(unzipped_file, "rb") do |f|
        buffer = ""

        square_side.times.map {
          f.read(CHUNK_SIZE * square_side, buffer)
          buffer.unpack("#{PACKING}*")
        }.compact
      end
    end
  end
end
