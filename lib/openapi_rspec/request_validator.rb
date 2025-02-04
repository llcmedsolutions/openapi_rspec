# frozen_string_literal: true

require 'dry-initializer'
require 'rack/test'
require 'uri'

module OpenapiRspec
  class RequestValidator
    extend Dry::Initializer
    include Rack::Test::Methods

    option :path
    option :proxy
    option :method
    option :code
    option :media_type
    option :path_params
    option :params
    option :query
    option :headers

    attr_reader :response, :result

    def app
      OpenapiRspec.app
    end

    def matches?(doc)
      @result = doc.validate_request(path: path, method: method, code: code, media_type: media_type)
      return false unless result.valid?

      perform_request(doc)
      result.validate_response(body: response.body, code: response.status)
      result.valid?
    end

    def description
      "return valid response with code #{code} on `#{method.to_s.upcase} #{path}`"
    end

    def failure_message
      if response
        (%W[Response: #{response.body}] + result.errors).join("\n")
      else
        result.errors.join("\n")
      end
    end

    private

    def perform_request(doc)
      headers.each do |key, value|
        header key, value
      end
      request(request_uri(doc), method: method, **request_params)
      @response = last_response
    end

    def request_uri(doc)
      request_path = proxy.present? ? proxy : path
      request_path.scan(/\{([^}]*)\}/).each do |param|
        key = param.first.to_sym
        if path_params && path_params[key]
          @path = request_path.gsub "{#{key}}", path_params[key].to_s
        else
          raise URI::InvalidURIError, "No substitution data found for {#{key}}" \
            " to test the path #{request_path}."
        end
      end
      "#{doc.api_base_path}#{request_path}?#{URI.encode_www_form(query)}"
    end

    def request_params
      {
        headers: headers,
        params: params
      }
    end
  end
end
