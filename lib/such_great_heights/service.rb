module SuchGreatHeights
  class Service
    include SrtmConversions

    def initialize(tile_set, tile_loader: TileLoader)
      @tile_set   = tile_set
      @tile_cache = {}
      @tile_loader = tile_loader
    end

    attr_reader :tree, :tile_cache, :tile_set, :tile_loader
    private :tree, :tile_cache, :tile_loader

    def altitude_for(lon, lat)
      tile(lon, lat).altitude_for(lon, lat)
    end

    private

    def tile(lon, lat)
      tn = lon_lat_to_tile(lon, lat)
      tile_cache.fetch(tn) { tile_cache[tn] = load_tile(tn) }
    end

    def load_tile(tile_name)
      tile_loader.load(File.join(tile_set, tile_name))
    end
  end
end
