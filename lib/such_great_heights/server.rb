require "reel"
require "yaml"

module SuchGreatHeights
  # Receives connections from HTTP clients and either promotes them to
  # WebSocket clients or responds directly.
  class Server < Reel::Server::HTTP
    trap_exit :client_disconnected

    # @param host [String] the hostname to which to bind
    # @param port [Fixnum] the port to which to bind
    def initialize(host = "0.0.0.0", port = 7331)
      super host, port, &method(:on_connection)

      @clients = []

      ServiceSupervisionGroup.run!

      Celluloid.logger = Configuration.current.logger
    end

    private

    def on_connection(connection)
      connection.each_request do |request|
        if request.websocket?
          connection.detach
          @clients << Client.new_link(request.websocket,
                                      Celluloid::Actor[:service])
        else
          handle_request(request)
        end
      end
    end

    def handle_request(request)
      HttpHandler.new(request, Celluloid::Actor[:service]).response
    end

    def client_disconnected(client, _)
      @clients.delete(client)
    end
  end
end
