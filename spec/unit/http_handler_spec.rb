# frozen_string_literal: true

require "spec_helper"

require "cgi"

describe SuchGreatHeights::HttpHandler do
  let(:service) { double("service") }

  let(:headers) { described_class::DEFAULT_HEADERS }
  subject { SuchGreatHeights::HttpHandler.new(request, service) }

  describe "#response" do
    describe "fetching altitude for point" do
      let(:response) { SuchGreatHeights::AltitudeResponse.new(1337) }

      describe "from query string" do
        let(:request) do
          double("request", method: "GET", path: "/altitude", query_string: query_string)
        end

        describe "with all arguments" do
          let(:query_string) { "lat=-22.123&lng=-43.456" }

          it "responds with altitude as JSON" do
            expect(service).to receive(:altitude_for).with(-43.456, -22.123)
                                                     .and_return(response)
            expect(request).to receive(:respond).with(:ok, headers, response.to_json)

            subject.response
          end
        end

        describe "with missing arguments" do
          let(:query_string) { "lat=-22.123" }

          it "responds with 400" do
            expect(request).to receive(:respond).with(400, headers, /check/i)

            subject.response
          end
        end
      end

      describe "from request body" do
        let(:request) { double(:request, method: "POST", path: "/altitude", body: body) }

        describe "with a well-formed request" do
          let(:body) { { lng: -43.456, lat: -22.123 }.to_json }

          it "responds with altitude as JSON" do
            expect(service).to receive(:altitude_for).with(-43.456, -22.123)
                                                     .and_return(response)
            expect(request).to receive(:respond).with(:ok, headers, response.to_json)

            subject.response
          end
        end

        describe "with a malformed request" do
          let(:body) { "{ lat: " }

          it "responds with 400" do
            expect(request).to receive(:respond).with(400, headers, /check/i)

            subject.response
          end
        end
      end
    end

    describe "fetching profile for route" do
      let(:response) { SuchGreatHeights::ProfileResponse.new([13, 37]) }

      describe "from query string" do
        let(:request) do
          double(:request, method: "GET", path: "/profile", query_string: query_string)
        end

        describe "with all arguments" do
          let(:query_string) do
            "route=#{CGI.escape('[[-44.123,-22.456],[-45.123,-23.456]]')}"
          end

          it "responds with a route profile as JSON" do
            expect(service).to receive(:route_profile)
              .with({ "coordinates" => [[-44.123, -22.456], [-45.123, -23.456]] },
                    interpolate: true)
              .and_return(response)
            expect(request).to receive(:respond).with(:ok, headers, response.to_json)

            subject.response
          end
        end

        describe "with missing arguments" do
          let(:query_string) { "" }

          it "responds with 400" do
            expect(request).to receive(:respond).with(400, headers, /check/i)

            subject.response
          end
        end

        describe "with malformed arguments" do
          let(:query_string) { "route=#{CGI.escape('[[-44.123, -22.456],')}" }

          it "responds with 400" do
            expect(request).to receive(:respond).with(400, headers, /check/i)

            subject.response
          end
        end
      end

      describe "from request body" do
        let(:request) { double(:request, method: "POST", path: "/profile", body: body) }
        let(:body) { geo_json.to_json }

        describe "with a well-formed request" do
          let(:geo_json) do
            {
              "type" => "LineString",
              "coordinates" => [[-44.123, -22.456], [-45.123, -23.456]]
            }
          end

          it "responds with a route profile as JSON" do
            expect(service).to receive(:route_profile)
              .with(geo_json, interpolate: true).and_return(response)
            expect(request).to receive(:respond).with(:ok, headers, response.to_json)

            subject.response
          end
        end

        describe "with a malformed request" do
          let(:geo_json) { {} }

          it "responds with 400" do
            expect(request).to receive(:respond).with(400, headers, /check/i)
            expect(service).to receive(:route_profile)
              .with({}, interpolate: true).and_raise(KeyError)

            subject.response
          end
        end
      end
    end
  end
end
