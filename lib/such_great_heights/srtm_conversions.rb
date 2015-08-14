module SuchGreatHeights
  # Performs conversions between tile references and coordinate pairs.
  module SrtmConversions
    # Converts a coordinate pair into tile name, in the format
    # "[S|N]00[W|E]000.hgt.zip".
    #
    # @example
    #   converter = Object.new.extend(SuchGreatHeights::SrtmConversions)
    #   converter.lon_lat_to_tile(-43.123, -22.123) # => "S23W044.hgt.zip"
    #   converter.lon_lat_to_tile(43.123, 22.123) # => "N22E043.hgt.zip"
    #
    # @param lon [Float] a longitude
    # @param lat [Float] a latitude
    # @return [String] a tile name
    def lon_lat_to_tile(lon, lat)
      tlat = coord_to_tile_ref(lat).rjust(2, "0")
      tlon = coord_to_tile_ref(lon).rjust(3, "0")

      format("%s%s%s%s.hgt.zip", north_south(lat), tlat, east_west(lon), tlon)
    end

    # Converts a tile name into a coordinate pair.
    #
    # @example
    #   converter = Object.new.extend(SuchGreatHeights::SrtmConversions)
    #   converter.tile_to_lon_lat("S23W044.hgt.zip") # => [-44, -23]
    #   converter.tile_to_lon_lat("N22E043.hgt.zip") # => [43, 22]
    #
    # @param tile_name [String] a tile name in the format "[S|N]00[W|E]000.hgt.zip"
    # @return [Pair<Float>] an Array with a longitude and a latitude
    def tile_to_lon_lat(tile_name)
      /(?<ns>[NS])(?<lat>\d+)(?<ew>[EW])(?<lon>\d+)\.hgt/ =~ tile_name

      [ew == "E" ? lon.to_i : -lon.to_i,
       ns == "N" ? lat.to_i : -lat.to_i]
    end

    private

    def coord_to_tile_ref(coord)
      (coord < 0 ? coord - 1 : coord).to_i.abs.to_s
    end

    def north_south(lat)
      lat <= 0 ? "S" : "N"
    end

    def east_west(lon)
      lon <= 0 ? "W" : "E"
    end
  end
end

converter = Object.new.extend(SuchGreatHeights::SrtmConversions)
converter.tile_to_lon_lat("S23W044.hgt.zip") # => [-44, -23]
