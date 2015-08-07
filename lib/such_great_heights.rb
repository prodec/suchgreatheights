module SuchGreatHeights
  SRTM1_SIDE = 3601
  SRTM3_SIDE = 1201
  NO_DATA    = -32_768
  ARCSECOND  = (1 / 3600.0) # in degrees
  DEFAULT_TILE_DURATION = 6 * 60 * 60 # hours in seconds
end

require_relative "such_great_heights/configuration"
require_relative "such_great_heights/commands"
require_relative "such_great_heights/errors"
require_relative "such_great_heights/geometry"
require_relative "such_great_heights/srtm_conversions"
require_relative "such_great_heights/srtm_tile"
require_relative "such_great_heights/null_tile"
require_relative "such_great_heights/tile_loader"
require_relative "such_great_heights/tile_data_loader"
require_relative "such_great_heights/tile_data"
require_relative "such_great_heights/point"
require_relative "such_great_heights/vector"
require_relative "such_great_heights/service"
require_relative "such_great_heights/http_handler"
require_relative "such_great_heights/altitude_response"
require_relative "such_great_heights/profile_response"
require_relative "such_great_heights/tile_cache"
require_relative "such_great_heights/service_logger"
require_relative "such_great_heights/service_supervision_group"

require_relative "such_great_heights/server"
require_relative "such_great_heights/client"
require_relative "such_great_heights/client_socket_listener"
