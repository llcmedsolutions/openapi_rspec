# frozen_string_literal: true

module OpenapiRspec
  module ModuleHelpers
    def validate_code(code, &block)
      specify do |example|
        metadata = example.metadata[:openapi_rspec]
        validator = RequestValidator.new(**request_params(metadata), code: code)
        expect(subject).to validator
        instance_exec validator, &block if block
      end
    end

    def proxy(&block)
      let(:proxy_uri, &block)
    end

    def params(&block)
      let(:openapi_rspec_params, &block)
    end

    def media_type(&block)
      let(:openapi_rspec_media_type, &block)
    end

    def headers(&block)
      let(:openapi_rspec_headers, &block)
    end

    def query(&block)
      let(:openapi_rspec_query, &block)
    end

    def get(*args, &block)
      process(:get, *args, &block)
    end

    def post(*args, &block)
      process(:post, *args, &block)
    end

    def put(*args, &block)
      process(:put, *args, &block)
    end

    def delete(*args, &block)
      process(:delete, *args, &block)
    end

    def head(*args, &block)
      process(:head, *args, &block)
    end

    def patch(*args, &block)
      process(:patch, *args, &block)
    end

    def process(method, uri)
      metadata[:openapi_rspec] = {uri: uri, method: method}
      let(:openapi_rspec_media_type) { "application/json" }
      let(:openapi_rspec_params) { {} }
      let(:openapi_rspec_headers) { {} }
      let(:openapi_rspec_query) { {} }
      context "#{method.to_s.upcase} #{uri}" do
        yield if block_given?
      end
    end
  end
end
