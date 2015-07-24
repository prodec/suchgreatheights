module SuchGreatHeights
  class Configuration
    def initialize(tile_set_path, tile_duration)
      @tile_set_path = tile_set_path
      @tile_duration = tile_duration
    end

    attr_reader :tile_set_path, :tile_duration

    def self.load_from_file
      config = YAML.load(open(configuration_path))

      Configuration.new(config.fetch("tile_set_path"),
                        config.fetch("tile_duration", DEFAULT_TILE_DURATION).to_f)
    end

    def self.configuration_path
      path = File.expand_path("../../config/suchgreatheights.yml", __dir__)
      fail "A configuration file is missing. Check the documentation" if !File.exist?(path)

      path
    end
  end
end
