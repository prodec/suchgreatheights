require "yaml"
require "logger"

module SuchGreatHeights
  class Configuration
    def initialize(tile_set_path, tile_duration, log_path)
      @tile_set_path = tile_set_path
      @tile_duration = tile_duration
      @log_path      = log_path
    end

    attr_reader :tile_set_path, :tile_duration, :log_path

    def logger
      @logger ||= Logger.new(log_path)
    end

    def self.current
      @configuration ||= load_from_file
    end

    def self.load_from_file
      config = YAML.load(open(configuration_path))

      Configuration.new(config.fetch("tile_set_path"),
                        config.fetch("tile_duration", DEFAULT_TILE_DURATION).to_f,
                        config.fetch("log_path", "log/suchgreatheights.log"))
    end

    def self.configuration_path
      path = File.expand_path("../../config/suchgreatheights.yml", __dir__)
      fail "A configuration file is missing. Check the documentation" if !File.exist?(path)

      path
    end
  end
end
