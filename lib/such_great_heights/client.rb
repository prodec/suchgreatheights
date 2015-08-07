require "celluloid"

module SuchGreatHeights
  class Client
    include Celluloid

    MALFORMED_REQUEST = {
      response: "error",
      data: { message: "You've sent a malformed request" }
    }

    UNKNOWN_COMMAND = {
      response: "error",
      data: { message: "Unknown command." }
    }

    START_LISTENER = lambda do |client, connection|
      ClientSocketListener.new_link(client, connection)
    end

    def initialize(connection, service)
      @connection = connection
      @service    = service
      @listener   = if block_given?
                      yield Actor.current, connection
                    else
                      START_LISTENER.call(Actor.current, connection)
                    end
    end

    attr_reader :service, :connection
    private :service, :connection

    def process_request(request)
      send_response(request) do
        prepare_response(request)
      end
    end

    private

    def send_response(request)
      response = {
        client_sent_at: request["sent_at"],
        response: request.fetch("command"),
        data: yield,
        processed_at: (Time.now.to_f * 1000).to_i
      }

      connection << response.to_json
    end

    def prepare_response(request)
      payload = request["payload"]

      case request.fetch("command")
      when Commands::POINT_ALTITUDE
        service.altitude_for(payload.fetch("lng"), payload.fetch("lat"))
      when Commands::ROUTE_PROFILE
        service.route_profile(payload.fetch("route"))
      when Commands::HEARTBEAT
        nil
      else
        UNKNOWN_COMMAND
      end
    rescue KeyError, NameError
      MALFORMED_REQUEST
    end
  end
end
