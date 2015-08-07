require "celluloid"

module SuchGreatHeights
  class ClientSocketListener
    include Celluloid

    def initialize(client, connection)
      @client     = client
      @connection = connection

      async.listen
    end

    attr_reader :client, :connection
    private :client, :connection

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
