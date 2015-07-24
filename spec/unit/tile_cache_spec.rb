require "spec_helper"

describe SuchGreatHeights::TileCache do
  let(:loader) { class_double("TileLoader") }
  let(:tile_set) { "/path/to/set" }
  let(:duration) { 2.0 }
  let(:latitude) { -1 }
  let(:longitude) { -1 }
  let(:tile_path) { File.join(tile_set, lon_lat_to_tile(longitude, latitude)) }

  include SuchGreatHeights::SrtmConversions

  subject {
    SuchGreatHeights::TileCache.new(tile_set: tile_set, tile_duration: duration,
                                    tile_loader: loader)
  }

  describe "#fetch" do
    before do
      expect(loader).to receive(:load).with(tile_path).twice
    end

    it "removes Tiles cache after duration has expired" do
      subject.fetch(longitude, latitude) # fetched for the first time
      sleep(duration / 2.0)
      subject.fetch(longitude, latitude) # hits cached tiled, resets timer
      sleep(duration + 0.1)
      subject.fetch(longitude, latitude) # has to fetch again
    end
  end
end
