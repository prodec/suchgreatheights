module SuchGreatHeights
  ProfileResponse = Struct.new(:profile) do
    def to_json
      { profile: profile }.to_json
    end
  end
end
