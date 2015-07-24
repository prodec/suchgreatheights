require "celluloid"

module SuchGreatHeights
  class ServiceSupervisionGroup < Celluloid::SupervisionGroup
    supervise TileCache, as: :tile_cache
    supervise Service, as: :service
  end
end
