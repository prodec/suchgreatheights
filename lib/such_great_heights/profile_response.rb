module SuchGreatHeights
  # Takes care of serializing profiles (an [Array<Point>]) to JSON.
  ProfileResponse = Struct.new(:profile) do
    def to_json(*)
      { profile: profile }.to_json
    end
  end
end
