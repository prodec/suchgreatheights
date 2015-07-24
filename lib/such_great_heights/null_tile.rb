require "singleton"

module SuchGreatHeights
  class NullTile
    include Singleton

    def altitude_for(*)
      NO_DATA
    end
  end
end
