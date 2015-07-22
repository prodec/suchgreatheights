require "cgi"

module SuchGreatHeights
  class HttpHandler
    def initialize(request, service)
      @request = request
      @service = service
    end

    attr_reader :request, :service

    def response
      request.respond(:ok, build_response.to_json)
    rescue TypeError, KeyError, JSON::ParserError
      request.respond(400, "cannot process request. Check your arguments.")
    rescue => e
      request.respond(500, e.message)
    end

    private

    def build_response
      case request.path
      when "/altitude"
        service.altitude_for(Float(params["lon"]), Float(params["lat"]))
      when "/profile"
        service.route_profile(route_from_params)
      end
    end

    def route_from_params
      if request.method == "GET"
        { "coordinates" => JSON.load(params.fetch("route")) }
      else
        params
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
      (request.query_string || "").split("&").map { |kv|
        k, v = kv.split("=")
        [CGI.unescape(k), CGI.unescape(v)] if k && v
      }.compact.to_h
    end

    def params_from_body
      contents = request.body.to_s
      JSON.load(contents.empty? ? "{}" : contents)
    end
  end
end
