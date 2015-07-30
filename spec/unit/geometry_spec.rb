require "spec_helper"

describe SuchGreatHeights::Geometry do
  G = SuchGreatHeights::Geometry

  describe ".interpolate_route" do
    let(:factory) {
      RGeo::Geographic.simple_mercator_factory
    }
    let(:acceptable_distance) { 0.0000001 }

    generative do
      # This is range limited because of some corrections RGeo applies
      # to lines whose pairs of points vary over 180 degrees in the x
      # coordinate.
      data(:route) { generate(:route, longitude_min: -80, longitude_max: 80) }

      it "doesn't stray from the original route" do
        ls0 = factory.line_string(route.map { |p| factory.point(p.x, p.y) })
        interpolated = G.interpolate_route(route)
        ps = interpolated.map { |p| factory.point(p.x, p.y) }
        all_on_line = ps.all? { |p| p.distance(ls0) < acceptable_distance }

        expect(all_on_line).to be(true)
      end
    end
  end
end
