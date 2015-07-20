require "spec_helper"

describe SuchGreatHeights::SrtmTile do
  let(:tile) { File.expand_path("../assets/S22W043.hgt.zip", __dir__) }

  subject { SuchGreatHeights::SrtmTile.new(tile) }

  generative do
    data(:longitude) { -43 + (generate(:integer, min: 0, max: 100_000).abs / 100_000.0) }
    data(:latitude) { -22 + (generate(:integer, min: 0, max: 100_000).abs / 100_000.0) }

    it "finds an altitude for a given coordinate pair" do
      expect(subject.altitude_for(longitude, latitude)).not_to be_nil
    end
  end
end
