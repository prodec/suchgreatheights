module SuchGreatHeights
  class TileCache
    include SrtmConversions
    include Celluloid
    include Celluloid::Notifications

    FROM_CONFIG = ->(key) { Configuration.current.public_send(key) }

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
