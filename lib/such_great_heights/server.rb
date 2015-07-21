require "reel"

module SuchGreatHeights
  class Server < Reel::Server::HTTP
    trap_exit :client_disconnected

    def initialize(host = "0.0.0.0", port = 7331)
      super host, port, &method(:on_connection)

      @clients = []
      @tile    = Service.new(File.expand_path("../../data/original/South_America", __dir__))
    end

    attr_reader :tile

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
  end
end
