CoordinateGenerator = lambda do |min, max|
  lambda do |opts = {}|
    int  = opts[:base] ||
           Generative.generate(:integer, min: opts[:min] || min,
                                         max: opts[:max] || max)
    frac = Generative.generate(:integer, min: 0, max: 100_000).abs / 100_000.0

    int + (opts[:decrease] ? -frac : frac)
  end
end

LongitudeGenerator = CoordinateGenerator.call(-180, 180)
LatitudeGenerator  = CoordinateGenerator.call(-90, 90)

CoordinatePairGenerator = lambda do |opts = {}|
  SuchGreatHeights::Vector.new(
    Generative.generate(:longitude,
                        min: opts[:longitude_min],
                        max: opts[:longitude_max],
                        base: opts[:latitude_base]),
    Generative.generate(:latitude,
                        min: opts[:latitude_min],
                        max: opts[:latitude_max],
                        base: opts[:latitude_base])
  )
end

RouteGenerator = lambda do |opts = {}|
  Array.new((Generative.generate(:integer, min: 10, max: 100))) do
    Generative.generate(:coordinate_pair, opts)
  end
end

Generative.register_generator(:longitude, LongitudeGenerator)
Generative.register_generator(:latitude, LatitudeGenerator)
Generative.register_generator(:coordinate_pair, CoordinatePairGenerator)
Generative.register_generator(:route, RouteGenerator)
