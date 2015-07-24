require "spec_helper"

describe SuchGreatHeights::Service do
  include SuchGreatHeights::SrtmConversions

  let(:cache) { class_double("TileCache") }

  subject { SuchGreatHeights::Service.new(tile_cache: cache) }

  describe "#altitude_for" do
    let(:tile) { instance_double("Tile") }
    let(:longitude) { -42.123123 }
    let(:latitude) { -21.123123 }

    generative do
      data(:latitude) { generate(:integer, min: -90, max: 90) }
      data(:longitude) { generate(:integer, min: -180, max: 180) }
      data(:altitude) { generate(:integer, min: 0, max: 3250) }

      it "loads the appropriate tile and fetches altitude" do
        expect(cache).to receive(:fetch).with(longitude, latitude)
          .and_return(tile)

        expect(tile).to receive(:altitude_for).with(longitude, latitude)
          .and_return(altitude)

        expect(subject.altitude_for(longitude, latitude).altitude).to eq(altitude)
      end
    end
  end
end
