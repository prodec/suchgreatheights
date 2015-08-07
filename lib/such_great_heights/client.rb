require "celluloid"

module SuchGreatHeights
  class Client
    include Celluloid
    include Celluloid::Notifications

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
      @client_ip  = connection.remote_ip
      @listener   = if block_given?
                      yield Actor.current, connection
                    else
                      START_LISTENER.call(Actor.current, connection)
                    end

      log_connection
    end

    attr_reader :service, :connection, :client_ip
    private :service, :connection, :client_ip

    def process_request(request)
      send_response(request) do
        prepare_response(request)
      end
    end

    def disconnect
      log_disconnection
      terminate
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

    def log_connection
      publish(ServiceLogger::EVENT, "Client connected (IP: #{client_ip})")
    end

    def log_disconnection
      publish(ServiceLogger::EVENT, "Client disconnected (IP: #{client_ip})")
    end
  end
end
