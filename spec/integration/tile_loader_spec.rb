require "spec_helper"

require "securerandom"

describe SuchGreatHeights::TileLoader do
  let(:inexistent) { SecureRandom.hex(16) }
  let(:actual_tile) { File.expand_path("../assets/S22W043.hgt.zip", __dir__) }
  let(:bad_tile) { File.expand_path("../assets/botched.hgt.zip", __dir__) }

  it "returns a NullTile if the file doesn't exist" do
    expect(subject.load(inexistent)).to be_instance_of(SuchGreatHeights::NullTile)
  end

  it "returns an SrtmTile if the file is on disk" do
    expect(subject.load(actual_tile)).to be_instance_of(SuchGreatHeights::SrtmTile)
  end

  it "returns a NullTile if the data has the wrong dimensions" do
    expect(subject.load(bad_tile)).to be_instance_of(SuchGreatHeights::NullTile)
  end
end
