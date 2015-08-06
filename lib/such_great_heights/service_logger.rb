require_relative "configuration"

module SuchGreatHeights
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

    def event(_, message)
      logger.debug(message)
    end
  end
end
