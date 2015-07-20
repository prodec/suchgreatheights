require_relative "such_great_heights/errors"
require_relative "such_great_heights/srtm_conversions"
require_relative "such_great_heights/srtm_tile"
require_relative "such_great_heights/tile_loader"
require_relative "such_great_heights/tile_data_loader"
require_relative "such_great_heights/tile_data"
require_relative "such_great_heights/service"

require_relative "such_great_heights/server"
require_relative "such_great_heights/client"

module SuchGreatHeights
  SRTM1_SIDE = 3601
  SRTM3_SIDE = 1201
  NO_DATA    = -32_768
end
