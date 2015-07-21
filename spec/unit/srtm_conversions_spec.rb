require "spec_helper"

describe SuchGreatHeights::SrtmConversions do
  subject { Object.new.extend(SuchGreatHeights::SrtmConversions) }

  describe "#lon_lat_to_tile" do
    generative do
      data(:latitude) { generate(:integer, min: -90, max: 90) }
      data(:longitude) { generate(:integer, min: -180, max: 180) }

      it "puts values in the right hemispheres" do
        tile_name = subject.lon_lat_to_tile(longitude, latitude)
        lon, lat  = subject.tile_to_lon_lat(tile_name)

        expect(lat).to eq(latitude.floor.to_i - 1)
        expect(lon).to eq(longitude.floor.to_i - 1)
      end
    end
  end
end
