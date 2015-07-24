require "spec_helper"

describe SuchGreatHeights::TileLoader do
  describe ".load" do
    let(:good_tile) { File.expand_path("../assets/S22W043.hgt.zip", __dir__) }
    let(:bad_tile) { "/fantasy/land/S99W250.hgt.zip" }

    it "returns an SrtmTile if the Tile exists" do
      expect(subject.load(good_tile)).to be_instance_of(SuchGreatHeights::SrtmTile)
    end

    it "returns a NullTile if the Tile doesn't exist" do
      expect(subject.load(bad_tile)).to be_instance_of(SuchGreatHeights::NullTile)
    end
  end
end
