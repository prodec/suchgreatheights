require "spec_helper"

RSpec::Matchers.define :be_within_acceptable_distance_of do |route|
  match do |interpolated|
    ls0 = factory.line_string(actual.map { |p| point(p) })
    ps = interpolated.map { |p| point(p) }
    all_on_line = ps.all? { |p| p.distance(ls0) < acceptable_distance }

    expect(all_on_line).to be(true)
  end

  failure_message do |_|
    "expected the interpolated route to be within an acceptalbe distance of the original route"
  end
end

describe SuchGreatHeights::Geometry do
  G = SuchGreatHeights::Geometry

  describe ".interpolate_route" do
    let(:factory) { RGeo::Geographic.simple_mercator_factory }
    let(:acceptable_distance) { 0.0000001 }

    generative do
      # This is range limited because of some corrections RGeo applies
      # to lines whose pairs of points vary over 180 degrees in the x
      # coordinate.
      data(:route) { generate(:route, longitude_min: -80, longitude_max: 80) }
      data(:negative_factor) { generate(:integer, min: -123123123, max: 0) }

      it "doesn't stray from the original route" do
        expect(G.interpolate_route(route))
          .to be_within_acceptable_distance_of(route)
      end

      it "returns the route itself if the dist_factor is less than or equal to 0" do
        expect(G.interpolate_route(route, negative_factor)).to eq(route)
      end

      it "changes the resolution based on distance factor" do
        should_be_more = G.interpolate_route(route, 200.0)
        should_be_less = G.interpolate_route(route, 100.0)
        should_be_even_less = G.interpolate_route(route, 50)

        expect(should_be_more.size).to be > should_be_less.size
        expect(should_be_less.size).to be > should_be_even_less.size
      end

      it "doesn't stray from the original line when changing resolution" do
        expect(G.interpolate_route(route, 100))
          .to be_within_acceptable_distance_of(route)
        expect(G.interpolate_route(route, 50))
          .to be_within_acceptable_distance_of(route)
      end
    end

    def point(p)
      factory.point(p.x, p.y)
    end
  end
end
