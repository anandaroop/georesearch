# frozen_string_literal: true

require "ruby_llm"
require "ruby_llm/schema"

module Georesearch
  module Agents
    class BBoxer
      attr_reader :response, :usage

      SCHEMA = RubyLLM::Schema.create do
        number :east, description: "The easternmost longitude of the bounding box"
        number :west, description: "The westernmost longitude of the bounding box"
        number :south, description: "The southernmost latitude of the bounding box"
        number :north, description: "The northernmost latitude of the bounding box"
      end

      GEOJSON_SCHEMA = RubyLLM::Schema.create do
        string :type, description: "The type of the GeoJSON object, should be 'Feature'"
        object :geometry, description: "The geometry of the GeoJSON object" do
          string :type, description: "The type of geometry, should be 'Polygon'"
          array :coordinates, description: "The coordinates of the geometry" do
            array :coordinate_pair, description: "A pair of coordinates [longitude, latitude]" do
              number :longitude, description: "The longitude"
              number :latitude, description: "The latitude"
            end
          end
        end
        object :properties, description: "Properties of the GeoJSON object, can be empty" do
          string :name, description: "The name of the place"
        end
      end

      SW_NE_CORNERS_SCHEMA = RubyLLM::Schema.create do
        object :sw, description: "The southwest corner of the bounding box" do
          number :lng, description: "The longitude of the southwest corner"
          number :lat, description: "The latitude of the southwest corner"
        end
        object :ne, description: "The northeast corner of the bounding box" do
          number :lng, description: "The longitude of the northeast corner"
          number :lat, description: "The latitude of the northeast corner"
        end
      end

      OGRNE_SCHEMA = RubyLLM::Schema.create do
        string :bounds, description: "The bounding box in the format: 'xmin ymin xmax ymax'"
      end

      INSTRUCTIONS = <<~INSTRUCTIONS
        You are a research assistant specializing in finding bounding boxes for geographical entities.

        If given multiple places, think step by step about how to combine them to get the smallest bounding box that contains all of them.
        Even so, respond only according to the schema, nothing more or less, no markdown, no codefence, no yapping.

        Your response should follow the provided schema exactly,
        nothing more or less, no markdown, no codefence, no yapping.

        <SCHEMA>
      INSTRUCTIONS

      def self.search(place: nil, format: "geojson")
        searcher = new(place: place, format: format)
        searcher.response
      end

      def initialize(place: nil, format: "geojson")
        raise ArgumentError, "A valid place description must be provided" if place.nil? || place.to_s.strip.empty?

        # geo_mcp = RubyLLM::MCP.client(
        #   name: "geomcp",
        #   transport_type: :streamable,
        #   request_timeout: 15000, # Optional: timeout in milliseconds (default: 8000)
        #   config: {
        #     url: ENV["GEORESEARCH_MCP_SERVER_URL"],
        #     headers: {}
        #   }
        # )

        selected_schema = {
          "raw" => SCHEMA,
          "geojson" => GEOJSON_SCHEMA,
          "swne" => SW_NE_CORNERS_SCHEMA,
          "ogrne" => OGRNE_SCHEMA
        }[format]

        chat = RubyLLM.chat(model: RubyLLM.config.default_model)
          .with_params(thinking: {
            type: "enabled",
            budget_tokens: 1000
          })
          .with_instructions(INSTRUCTIONS.gsub("<SCHEMA>", selected_schema.new.to_json))
          .with_schema(selected_schema)
        # .with_temperature(0.0)
        # .with_tools(*geo_mcp.tools)

        response = chat.ask "Find a bounding box for: #{place}"
        @response = response.content

        @usage = {
          timestamp: Time.now.utc.iso8601,
          caller: self.class.name,
          input: place,
          model_id: response.model_id,
          input_tokens: response.input_tokens,
          output_tokens: response.output_tokens
        }
      end
    end
  end
end
