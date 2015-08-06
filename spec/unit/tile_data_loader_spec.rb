require "spec_helper"

describe SuchGreatHeights::TileDataLoader do
  let(:valid_tile) { File.expand_path("../assets/S22W043.hgt.zip", __dir__) }
  let(:invalid_tile) { File.expand_path("../assets/botched.hgt.zip", __dir__) }

  describe ".load_tile" do
    it "validates tile dimensions" do
      expect do
        SuchGreatHeights::TileDataLoader.load_tile(valid_tile)
      end.not_to raise_error

      expect do
        SuchGreatHeights::TileDataLoader.load_tile(invalid_tile)
      end.to raise_error(SuchGreatHeights::WrongDimensionsError)
    end

    it "builds a TileData" do
      tile_data = SuchGreatHeights::TileDataLoader.load_tile(valid_tile)

      expect(tile_data.longitude).to eq(-43)
      expect(tile_data.latitude).to eq(-22)
      expect(tile_data.square_side).to eq(1201)
    end
  end
end
