require "spec_helper"

RSpec::Matchers.define :be_within_acceptable_distance_of do |route|
  match do |interpolated|
    ls0 = factory.line_string(actual.map { |p| point(p) })
    ps = interpolated.map { |p| point(p) }
    all_on_line = ps.all? { |p| p.distance(ls0) < acceptable_distance }

    expect(all_on_line).to be(true)
  end

  failure_message do |actual|
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

      it "doesn't stray from the original route" do
        expect(G.interpolate_route(route))
          .to be_within_acceptable_distance_of(route)
      end

      it "changes the resolution based on max_dist" do
        dist = max_dist(route)

        should_be_more = G.interpolate_route(route, dist)
        expect(max_dist(should_be_more)).to be <= dist

        should_be_less = G.interpolate_route(route, dist / 2.0)
        expect(max_dist(should_be_less)).to be <= (dist / 2.0)

        expect(should_be_more.size).to be > should_be_less.size
      end

      it "doesn't stray from the original line when changing resolution" do
        dist = max_dist(route)

        expect(G.interpolate_route(route, dist))
          .to be_within_acceptable_distance_of(route)
        expect(G.interpolate_route(route, dist / 2.0))
          .to be_within_acceptable_distance_of(route)
      end
    end

    def point(p)
      factory.point(p.x, p.y)
    end

    def max_dist(ps)
      ps.each_cons(2)
        .map { |a, b| point(a).distance(point(b)) }
        .max / 1000.0
    end
  end
end
