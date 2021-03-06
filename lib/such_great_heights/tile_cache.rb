module SuchGreatHeights
  # Loads and unloads tiles from disk, keeping them in memory for the
  # duration specified in Configuration#tile_duration.
  class TileCache
    include SrtmConversions
    include Celluloid
    include Celluloid::Notifications

    FROM_CONFIG = ->(key) { Configuration.current.public_send(key) }

    # @param tile_set [String] path to the tile set (defaults to
    #   Configuration.current.tile_set_path)
    # @param tile_duration [String] how long to keep the tile in memory,
    #   in seconds (defaults to Configuration.current.tile_set_path)
    def initialize(tile_set: FROM_CONFIG[:tile_set_path],
                   tile_duration: FROM_CONFIG[:tile_duration],
                   tile_loader: TileLoader)
      @tile_set      = tile_set
      @loader        = tile_loader
      @cache         = {}
      @tile_duration = tile_duration
      @timers        = {}
    end

    attr_reader :cache, :loader, :tile_set, :tile_duration, :timers
    private :cache, :loader, :tile_set, :tile_duration, :timers

    # Fetches a tile at a given coordinate pair.
    #
    # @param lon [Float] a longitude
    # @param lat [Float] a latitude
    # @return [SrtmTile] a tile
    def fetch(lon, lat)
      tn   = lon_lat_to_tile(lon, lat)
      tile = cache.fetch(tn) { cache[tn] = load_tile(tn) }

      update_timer(tn)

      tile
    end

    private

    def load_tile(tile_name)
      publish(ServiceLogger::EVENT, "Loading tile: #{tile_name}")

      loader.load(File.join(tile_set, tile_name))
    end

    def unload_tile(tile_name)
      publish(ServiceLogger::EVENT, "Unloading tile: #{tile_name}")

      cache.delete(tile_name)
    end

    def update_timer(tile_name)
      cancel_running_timer(tile_name)

      timers[tile_name] = after(tile_duration) do
        unload_tile(tile_name)
      end
    end

    def cancel_running_timer(tile_name)
      return if !(timer = timers[tile_name])
      timer.cancel
    end
  end
end
