require "singleton"

module SuchGreatHeights
  # A NullTile is used in lieu of an SrtmTile when the latter doesn't
  # exist in the filesystem. It defaults to returning
  # `SuchGreatHeights::NO_DATA` for every call to `altitude_for`.
  class NullTile
    include Singleton

    # @return [Fixnum] the value of SuchGreatHeights::NO_DATA
    def altitude_for(*)
      NO_DATA
    end
  end
end
