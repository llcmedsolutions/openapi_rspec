# frozen_string_literal: true

require "openapi_rspec"

OpenapiRspec.config.app = HelloWorldApp.new

RSpec.describe "API v1" do
  # do not forget additional_schemas
  subject { OpenapiRspec.api("./spec/data/openapi.yml", api_base_path: "/v1") }

  it "is valid openapi spec" do
    expect(subject).to validate_documentation
  end

  describe "/pets" do
    describe "POST" do
      post "/pets" do
        params { {name: "Lucky"} }

        validate_code(200)
      end
    end

    describe "GET" do
      get "/pets" do
        headers { {"X-Client-Device" => "ios"} }
        query { {tags: ["lucky"]} }

        validate_code(200) do |validator|
          result = JSON.parse(validator.response.body)
          expect(result.first["name"]).to eq("Lucky")
        end
      end
    end
  end

  describe "/pets/{id}" do
    describe "GET" do
      get "/pets/{id}" do
        let(:id) { 23 }

        validate_code(200)
      end
    end

    describe "PATCH" do
      context "with form data" do
        patch "/pets/{id}" do
          let(:id) { 23 }
          params { {name: new_name} }

          let(:new_name) { "Luke" }

          let(:expected_result) do
            {
              "id" => id,
              "name" => new_name
            }
          end

          validate_code(200) do |validator|
            result = JSON.parse(validator.response.body)
            expect(result).to eq expected_result
          end
        end
      end

      context "with JSON" do
        patch "/pets/{id}" do
          let(:id) { 23 }
          headers { {"CONTENT_TYPE" => "application/json"} }
          params { JSON.dump(name: new_name) }

          let(:new_name) { "Luke" }

          let(:expected_result) do
            {
              "id" => id,
              "name" => new_name
            }
          end

          validate_code(200) do |validator|
            result = JSON.parse(validator.response.body)
            expect(result).to eq expected_result
          end
        end
      end
    end

    describe "DELETE" do
      delete "/pets/{id}" do
        let(:id) { 23 }

        validate_code(204)
      end
    end

    describe "Proxy" do
      get '/pet' do
        proxy { '/domestic/pet/{id}' }
        let(:id) { 23 }
        validate_code(200)
      end
    end
  end
end
