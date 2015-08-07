module SuchGreatHeights
  module SrtmConversions
    def lon_lat_to_tile(lon, lat)
      tlat = coord_to_tile_ref(lat).rjust(2, "0")
      tlon = coord_to_tile_ref(lon).rjust(3, "0")

      format("%s%s%s%s.hgt.zip", north_south(lat), tlat, east_west(lon), tlon)
    end

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
