require "celluloid"
require "rgeo-geojson"

module SuchGreatHeights
  class Client
    include Celluloid

    def initialize(connection, service)
      @connection = connection
      @service    = service

      async.listen
    end

    attr_reader :service, :connection
    private :service, :connection

    def listen
      loop do
        execute_command(next_command)
      end
    end

    def point_altitude(lon, lat)
      connection << service.altitude_for(lon, lat).to_json
    end

    def route_profile(route)
      connection << service.route_profile(route).to_json
    end

    def execute_command(command)
      case command["command"]
      when "point_altitude"
        point_altitude(command["lon"], command["lat"])
      when "route_profile"
        route_profile(RGeo::GeoJSON.decode(command["route"]))
      end
    end

    def next_command
      JSON.parse(connection.read)
    rescue JSON::ParserError
      {}
    end
  end
end
