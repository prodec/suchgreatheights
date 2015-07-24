require "reel"
require "yaml"

module SuchGreatHeights
  class Server < Reel::Server::HTTP
    trap_exit :client_disconnected

    def initialize(host = "0.0.0.0", port = 7331)
      super host, port, &method(:on_connection)

      @clients = []
      @service = Service.new_link(configuration.tile_set_path,
                                  configuration.tile_duration)
    end

    attr_reader :service
    private :service

    private

    def on_connection(connection)
      connection.each_request do |request|
        if request.websocket?
          connection.detach
          @clients << Client.new_link(request.websocket, service)
        else
          handle_request(request)
        end
      end
    end

    def handle_request(request)
      HttpHandler.new(request, service).response
    end

    def client_disconnected(client, _)
      @clients.delete(client)
    end

    def configuration
      @configuration ||= Configuration.load_from_file
    end
  end
end
