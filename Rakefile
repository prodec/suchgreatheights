require "benchmark"
require "./lib/such_great_heights"

namespace :bench do
  task :tile_loading do
    desc "Benchmarks loading tiles"

    Benchmark.bmbm do |x|
      x.report("tile_loading") do
        tile_path = File.expand_path("spec/assets/S22W043.hgt.zip", __dir__)

        100.times do
          SuchGreatHeights::TileDataLoader.load_tile(tile_path)
        end
      end
    end
  end

  desc "Benchmarks finding altitudes"
  task :finding_altitudes do
    Benchmark.bmbm do |x|
      x.report("finding_altitudes") do
        tile_set_path = File.expand_path("spec/assets", __dir__)
        service = SuchGreatHeights::Service.new(tile_set_path)

        100_000.times do
          service.altitude_for(-42.123123123, -21.98123712)
        end
      end
    end
  end
end

task default: :bench
