require "celluloid"

module SuchGreatHeights
  # An Actor that reads from the connection and passes parsed commands
  # up to its owning Client.
  class ClientSocketListener
    include Celluloid

    # @param client [Client] the Client who owns this listener
    # @param connection [#read] the WebSocket connection
    def initialize(client, connection)
      @client     = client
      @connection = connection

      async.listen
    end

    attr_reader :client, :connection
    private :client, :connection

    private

    def listen
      loop do
        client.async.process_request(next_command)
      end
    rescue IOError
      client.async.disconnect
      terminate
    end

    def next_command
      JSON.parse(connection.read)
    rescue JSON::ParserError
      {}
    end
  end
end
