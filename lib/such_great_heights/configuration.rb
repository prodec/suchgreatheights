require "yaml"
require "logger"

module SuchGreatHeights
  # Represents the current configuration of the running system. It is
  # kept on disk as a YAML file, whose default path is
  # "<project_root>/config/suchgreatheights.yml". Its keys are:
  #
  # @example
  #   tile_set_path: "/path/to/tile_set"
  #   tile_duration: 21600 # 6 hours
  #   log_path: "/path/to/log/file.log" # optional
  #
  # @attr tile_set_path [String]
  # @attr tile_duration [Fixnum]
  # @attr log_path [String]
  class Configuration
    # @param tile_set_path [String] the path to the SRTM tile set on
    #   disk
    # @param tile_duration [Fixnum] how long to keep an [SrtmTile] in
    #   cache
    # @param log_path [String] a file path to be used as a log
    def initialize(tile_set_path, tile_duration, log_path)
      @tile_set_path = tile_set_path
      @tile_duration = tile_duration
      @log_path      = log_path
    end

    attr_reader :tile_set_path, :tile_duration, :log_path

    # @return [Logger]
    def logger
      @logger ||= Logger.new(log_path)
    end

    # The currently running Configuration, loaded from file on the
    # first call and then subsequently returned from memory.
    #
    # @return [Configuration]
    def self.current
      @configuration ||= load_from_file
    end

    # Loads a configuration file from disk.
    #
    # @return [Configuration]
    def self.load_from_file
      config = YAML.load(open(configuration_path))

      Configuration.new(config.fetch("tile_set_path"),
                        config.fetch("tile_duration", DEFAULT_TILE_DURATION).to_f,
                        config.fetch("log_path", "log/suchgreatheights.log"))
    end

    # Returns a configuration file path, checking if it exists in the process.
    #
    # @raise [StandardError] if file is not found
    # @return [String] the configuration file path
    def self.configuration_path
      path = File.expand_path("../../config/suchgreatheights.yml", __dir__)
      fail "A configuration file is missing. Check the documentation" if !File.exist?(path)

      path
    end
  end
end
