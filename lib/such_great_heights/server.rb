require "reel"
require "yaml"

module SuchGreatHeights
  class Server < Reel::Server::HTTP
    trap_exit :client_disconnected

    def initialize(host = "0.0.0.0", port = 7331)
      super host, port, &method(:on_connection)

      @clients = []
      @tile    = Service.new(tile_set_path)
    end

    attr_reader :tile
    private :tile

    private

    def on_connection(connection)
      connection.each_request do |request|
        if request.websocket?
          connection.detach
          @clients << Client.new_link(request.websocket, tile)
        end
      end
    end

    def client_disconnected(client, _)
      @clients.delete(client)
    end

    def tile_set_path
      YAML.load(config_file)["tile_set_path"]
    end

    def config_file
      path = File.expand_path("../../config/suchgreatheights.yml", __dir__)
      fail "A configuration file is missing. Check the documentation." if !File.exist?(path)

      path
    end
  end
end
