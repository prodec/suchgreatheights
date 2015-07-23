module SuchGreatHeights
  AltitudeResponse = Struct.new(:altitude) do
    def to_json(*)
      { altitude: altitude }.to_json
    end
  end
end
