require "./lib/such_great_heights"

G = SuchGreatHeights::Geometry
route = [[34.63458, -70.9861],
         [-64.82829, 8.68597]]
factory = RGeo::Geographic.simple_mercator_factory

interpolated = G.interpolate_route(route)
puts "\n ====== \n"
require "pp"; pp [G.distance(*route[0], *route[1]),
                  factory.point(*route[0]).distance(factory.point(*route[1])),
                  interpolated]
