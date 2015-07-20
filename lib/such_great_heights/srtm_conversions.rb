module SuchGreatHeights
  module SrtmConversions
    def lon_lat_to_tile(lon, lat)
      tlat = (lat.to_i - 1).abs.to_s.rjust(2, "0")
      tlon = (lon.to_i - 1).abs.to_s.rjust(3, "0")

      format("%s%s%s%s.hgt.zip", north_south(lat), tlat, east_west(lon), tlon)
    end

    def tile_to_lon_lat(tile_name)
      /(?<ns>[NS])(?<lat>\d+)(?<ew>[EW])(?<lon>\d+)\.hgt/ =~ tile_name

      [ew == "E" ? lon.to_i : -lon.to_i,
       ns == "N" ? lat.to_i : -lat.to_i]
    end

    private

    def north_south(lat)
      lat <= 0 ? "S" : "N"
    end

    def east_west(lon)
      lon <= 0 ? "W" : "E"
    end
  end
end
