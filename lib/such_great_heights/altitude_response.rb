module SuchGreatHeights
  # Builds a JSON response to the POINT_ALTITUDE command.
  AltitudeResponse = Struct.new(:altitude) do
    def to_json(*)
      { altitude: altitude }.to_json
    end
  end
end
