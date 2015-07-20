require "zip"

module SuchGreatHeights
  class TileLoader
    SRTM1_SIDE = 3601
    SRTM3_SIDE = 1201

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

        lon, lat = tile_coordinates
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
      chunk_size = [1].pack("n").size

      File.open(unzipped_file, "rb") do |f|
        buffer = ""

        square_side.times.map {
          f.read(chunk_size * square_side, buffer)
          buffer.unpack("n*")
        }.compact
      end
    end

    def tile_coordinates
      /(?<ns>[NS])(?<lat>\d+)(?<ew>[EW])(?<lon>\d+)\.hgt/ =~ filename

      [ew == "E" ? lon.to_i : lon.to_i * -1,
       ns == "N" ? lat.to_i : lat.to_i * -1]
    end
  end
end
