# frozen_string_literal: true

require "cgi"

module SuchGreatHeights
  # Handles requests to the [Service] coming from HTTP clients.
  #
  # @attr request [Reel::Request]
  # @attr service [Service]
  class HttpHandler
    DEFAULT_HEADERS = {
      "Content-Type" => "application/json"
    }.freeze

    # @param request [Reel::Request] the request
    # @param service [Service] the altitude service
    def initialize(request, service)
      @request = request
      @service = service
    end

    attr_reader :request, :service

    # Builds a response and sends it back to the client.
    #
    # @return [nil]
    def response
      request.respond(:ok, DEFAULT_HEADERS.dup, build_response.to_json)
    rescue TypeError, KeyError, JSON::ParserError
      request.respond(400, DEFAULT_HEADERS.dup,
                      "Cannot process request. Check your arguments.")
    rescue => e
      request.respond(500, DEFAULT_HEADERS.dup, e.message)
    end

    private

    def build_response
      case request.path
      when "/altitude"
        service.altitude_for(Float(params["lng"]), Float(params["lat"]))
      when "/profile"
        service.route_profile(route_from_params,
                              interpolate: params.fetch("interpolate", true))
      end
    end

    def route_from_params
      if request.method == "GET"
        { "coordinates" => JSON.load(params.fetch("route")) }
      else
        params.fetch("route")
      end
    end

    def params
      @params ||= if request.method == "GET"
                    params_from_query
                  else
                    params_from_body
                  end
    end

    def params_from_query
      (request.query_string || "").split("&").map do |kv|
        k, v = kv.split("=")
        [CGI.unescape(k), CGI.unescape(v)] if k && v
      end.compact.to_h
    end

    def params_from_body
      contents = request.body.to_s
      JSON.parse(contents.empty? ? "{}" : contents)
    end
  end
end
