require "spec_helper"

describe SuchGreatHeights::Service do
  include SuchGreatHeights::SrtmConversions

  let(:cache) { class_double("TileCache") }

  subject { SuchGreatHeights::Service.new(tile_cache: cache) }

  describe "#altitude_for" do
    let(:tile) { instance_double("Tile") }

    generative do
      data(:latitude) { generate(:integer, min: -90, max: 90) }
      data(:longitude) { generate(:integer, min: -180, max: 180) }
      data(:altitude) { generate(:integer, min: 0, max: 3250) }

      before do
        expect(cache)
          .to receive(:fetch)
          .with(longitude, latitude)
          .and_return(tile)

        expect(tile)
          .to receive(:altitude_for)
          .with(longitude, latitude)
          .and_return(altitude)
      end

      it "loads the appropriate tile and fetches altitude" do
        expect(subject.altitude_for(longitude, latitude).altitude).to eq(altitude)
      end
    end
  end

  describe "#route_profile" do
    let(:route) do
      {
        "type" => "LineString",
        "coordinates" => [
          [-42.123, -22.124],
          [-42.124, -22.123],
          [-42.125, -22.122]
        ]
      }
    end

    let(:route_profile) do
      subject.route_profile(route, interpolate: interpolate).profile
    end

    let(:cache) do
      Class.new do
        def tile
          @tile ||= Class.new do
            def altitude_for(*)
              2000
            end
          end.new
        end

        def fetch(*)
          tile
        end
      end.new
    end

    context "when interpolating" do
      let(:interpolate) { true }

      it "generates extra points when interpolating" do
        expect(route_profile.size).to be > route["coordinates"].size
        expect(route_profile.map(&:z).uniq).to eq([2000])
      end
    end

    context "when not interpolating" do
      let(:interpolate) { false }

      it "keeps the same number of points when not interpolating" do
        expect(route_profile.size).to eq(route["coordinates"].size)
        expect(route_profile.map(&:z).uniq).to eq([2000])
      end
    end
  end
end
