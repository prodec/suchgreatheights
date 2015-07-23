module SuchGreatHeights
  class TileCache
    include SrtmConversions
    include Celluloid

    TILE_DURATION = 6 * 60 * 60

    def initialize(tile_set, tile_duration: TILE_DURATION, tile_loader: TileLoader)
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
      tile = cache.fetch(tn) do cache[tn] = load_tile(tn) end

      update_timer(tn)

      tile
    end

    private

    def load_tile(tile_name)
      loader.load(File.join(tile_set, tile_name))
    end

    def unload_tile(tile_name)
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
