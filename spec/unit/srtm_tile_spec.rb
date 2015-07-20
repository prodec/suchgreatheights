require "spec_helper"

describe SuchGreatHeights::SrtmTile do
  let(:loader) { class_double("TileLoader") }
  let(:filename) { "S22W043.hgt.zip" }

  subject { SuchGreatHeights::SrtmTile.new(filename, tile_loader: loader) }

  describe "loading" do
    it "validates tiles that are of the wrong dimensions" do
      expect(loader).to receive(:load_tile).with(filename)
        .and_raise(SuchGreatHeights::WrongDimensionsError)

      expect {
        SuchGreatHeights::SrtmTile.new(filename, tile_loader: loader)
      }.to raise_error(SuchGreatHeights::WrongDimensionsError)
    end
  end

  describe "#altitude_for" do
    let(:tile_data) {
      instance_double("TileData",
                      data: raw_data, filename: filename.sub(".zip", ""),
                      square_side: 1201, longitude: -43, latitude: -22)
    }

    before do
      expect(loader).to receive(:load_tile).with(filename).and_return(tile_data)
    end

    generative do
      data(:longitude) { -43 + (generate(:integer, min: 0, max: 100_000).abs / 100_000.0) }
      data(:latitude) { -22 + (generate(:integer, min: 0, max: 100_000).abs / 100_000.0) }

      it "finds an altitude for a coordinate pair" do
        expect(subject.altitude_for(longitude, latitude)).not_to be_nil
      end
    end
  end

  def raw_data
    @raw_data ||= Array.new(1201) {
      Array.new(1201) { generate(:integer, min: 0, max: 300) }
    }
  end
end
