require_relative "configuration"

module SuchGreatHeights
  # Listens to events sent on the "new_request" channel and logs them
  # to file.
  class ServiceLogger
    include Celluloid
    include Celluloid::Notifications

    EVENT = "new_request"

    def initialize(config = Configuration.current)
      @logger = config.logger

      subscribe(EVENT, :event)
    end

    attr_reader :logger
    private :logger

    private

    def event(_, message)
      logger.debug(message)
    end
  end
end
