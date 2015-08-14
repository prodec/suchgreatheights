require "celluloid"

module SuchGreatHeights
  # A Client is an Actor sitting between a remote WebSocket client and
  # the system, receiving commands and sending back responses to the
  # other end.
  class Client
    include Celluloid
    include Celluloid::Notifications

    # Sent when a request is malformed (the command is known, but the
    # payload is incomplete, or wrong).
    MALFORMED_REQUEST = {
      response: "error",
      data: { message: "You've sent a malformed request" }
    }

    # Sent when a command is unknown.
    UNKNOWN_COMMAND = {
      response: "error",
      data: { message: "Unknown command." }
    }

    # Internal: Builds the default socket listener, linking it to the
    # Client.
    START_LISTENER = lambda do |client, connection|
      ClientSocketListener.new_link(client, connection)
    end

    # Starts up a Client. After everything is properly setup, notifies
    # the system that it has connected (as a Celluloid notification).
    #
    # @param connection [#read, #<<] the WebSocket connection
    # @param service [Service] the running service
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

    # Builds a response to a request and sends it back via the
    # connection.
    #
    # Requests follow the protocol below:
    #
    #   {
    #     "command" => String,
    #     "payload" => Hash,
    #     "sent_at" => Timestamp
    #   }
    #
    # @note All keys must be sent as Strings.
    #
    # @example
    #   client.process_request("command" => Commands::POINT_ALTITUDE,
    #                          "payload" => { lat: -22.123, lng: -43.321 })
    #
    # @param request [Hash] a request to be made to the Service
    # @return [nil]
    def process_request(request)
      send_response(request) do
        prepare_response(request)
      end
    end

    # Disconnects the Client, terminating the Celluloid actor in the
    # process and notifying the system.
    #
    # @return [nil]
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
      payload = request["payload"] || {}

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
    rescue KeyError
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
