require "celluloid"

module SuchGreatHeights
  # Binds together TileCache, Service and ServiceLogger, initializing
  # them at once and making sure they're all up at the same time.
  class ServiceSupervisionGroup < Celluloid::SupervisionGroup
    supervise TileCache, as: :tile_cache
    supervise Service, as: :service
    supervise ServiceLogger, as: :logger
  end
end
