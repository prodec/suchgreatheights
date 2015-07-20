require "celluloid"

module SuchGreatHeights
  class Client
    include Celluloid

    def initialize(connection, tile)
      @connection = connection
      @tile       = tile

      async.listen
    end

    def listen
      loop do
        execute_command(next_command)
      end
    end

    def fetch_altitude(lon, lat)
      @connection << { altitude: @tile.altitude_for(lon, lat) }.to_json
    end

    def execute_command(command)
      return if command["command"] != "fetch_altitude"

      @connection << fetch_altitude(command["lon"], command["lat"]).to_json
    end

    def next_command
      JSON.parse(@connection.read)
    rescue JSON::ParserError
      {}
    end
  end
end
