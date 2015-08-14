require "spec_helper"

describe SuchGreatHeights::SrtmTile do
  let(:loader) { class_double("TileLoader") }
  let(:filename) { "S22W043.hgt.zip" }

  subject { SuchGreatHeights::SrtmTile.new(filename, data_loader: loader) }

  describe "loading" do
    it "validates tiles that are of the wrong dimensions" do
      expect(loader).to receive(:load_tile).with(filename)
        .and_raise(SuchGreatHeights::WrongDimensionsError)

      expect do
        SuchGreatHeights::SrtmTile.new(filename, data_loader: loader)
      end.to raise_error(SuchGreatHeights::WrongDimensionsError)
    end
  end

  describe "querying" do
    let(:tile_data) do
      instance_double("TileData",
                      data: raw_data, filename: filename.sub(".zip", ""),
                      square_side: 1201, longitude: -43, latitude: -22)
    end

    before do
      expect(loader).to receive(:load_tile).with(filename).and_return(tile_data)
    end

    describe "#altitude_for" do
      generative do
        data(:longitude) { generate(:longitude, base: -43) }
        data(:latitude) { generate(:latitude, base: -22) }

        it "finds an altitude for a coordinate pair" do
          expect(subject.altitude_for(longitude, latitude)).not_to be_nil
        end
      end
    end
  end

  def raw_data
    @raw_data ||= Array.new(1201) do
      Array.new(1201) { generate(:integer, min: 0, max: 300) }
    end
  end
end
