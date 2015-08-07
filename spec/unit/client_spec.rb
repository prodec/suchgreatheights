require "spec_helper"

RSpec::Matchers.define :a_proper_response do
  match do |actual|
    res = JSON.parse(actual)
    res.key?("response") &&
      res.key?("data") &&
      res.key?("processed_at") &&
      res.key?("client_sent_at") &&
      !res.key("command") &&
      (res.fetch("processed_at") > sent_at)
  end
end

describe SuchGreatHeights::Client do
  let(:listener) { instance_double("ClientSocketListener") }
  let(:service) { instance_double("Service") }
  let(:connection) { double("connection", remote_ip: "1.2.3.4") }

  subject do
    SuchGreatHeights::Client.new(connection, service) do |_|
      listener
    end
  end

  describe "when processing known messages" do
    let(:sent_at) { Time.now.to_i - 10 }

    describe "like #{SuchGreatHeights::Commands::ROUTE_PROFILE}" do
      let(:profile_request) do
        {
          "command" => SuchGreatHeights::Commands::ROUTE_PROFILE,
          "payload" => {
            "route" => "bogus_route",
          },
          "sent_at" => sent_at
        }
      end

      let(:profile_response) do
        { profile: "bogus" }
      end

      it "fetches a route profile" do
        expect(service).to receive(:route_profile).with("bogus_route")
          .and_return(profile_response)
        expect(connection).to receive(:<<).with(a_proper_response)

        subject.process_request(profile_request)
      end

      it "returns an error if a route is missing" do
        expect(connection).to receive(:<<).twice.with(/malformed request/)

        subject.process_request(profile_request.merge("payload" => {}))
        subject.process_request(profile_request.reject { |k, _| k == "payload" })
      end
    end

    describe "like #{SuchGreatHeights::Commands::POINT_ALTITUDE}" do
      let(:altitude_request) do
        {
          "command" => SuchGreatHeights::Commands::POINT_ALTITUDE,
          "payload" => {
            "lat" => 0,
            "lng" => 0,
          },
          "sent_at" => sent_at
        }
      end

      let(:altitude_response) do
        { altitude: SuchGreatHeights::NO_DATA }
      end

      it "fetches an altitude" do
        expect(service).to receive(:altitude_for).with(0, 0)
          .and_return(altitude_response)
        expect(connection).to receive(:<<).with(a_proper_response)

        subject.process_request(altitude_request)
      end

      it "returns an error if lat is missing" do
        expect(connection).to receive(:<<).with(/malformed request/)
        payload = { "lat" => 0 }

        subject.process_request(altitude_request.merge("payload" => payload))
      end

      it "returns an error if lng is missing" do
        expect(connection).to receive(:<<).with(/malformed request/i)

        payload = { "lng" => 0 }

        subject.process_request(altitude_request.merge("payload" => payload))
      end
    end

    describe "like #{SuchGreatHeights::Commands::HEARTBEAT}" do
      let(:heartbeat_request) do
        {
          "command" => SuchGreatHeights::Commands::HEARTBEAT,
          "sent_at" => sent_at
        }
      end

      it "returns a heartbeat" do
        expect(connection).to receive(:<<).with(a_proper_response)

        subject.process_request(heartbeat_request)
      end
    end
  end

  describe "when processing unknown messages" do
    generative do
      data(:command) { generate(:string) }

      it "returns an error message" do
        expect(connection).to receive(:<<).with(/unknown/i)

        subject.process_request("command" => command)
      end
    end
  end
end
