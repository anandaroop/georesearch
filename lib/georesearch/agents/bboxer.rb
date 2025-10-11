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

      INSTRUCTIONS = <<~INSTRUCTIONS
        You are a research assistant specializing in finding bounding boxes for geographical entities.

        You often use the Geonames API to look up a bounding box for a country.

        If needed you look up multiple bounding boxes and combine them to form a larger bounding box.

        Your response should follow the provided schema exactly,
        nothing more or less, no markdown, no codefence, no yapping.

        Here is the schema:

        #{SCHEMA.new.to_json}
      INSTRUCTIONS

      def self.search(place: nil)
        searcher = new(place: place)
        searcher.response
      end

      def initialize(place: nil)
        raise ArgumentError, "A valid place description must be provided" if place.nil? || place.to_s.strip.empty?

        geo_mcp = RubyLLM::MCP.client(
          name: "geomcp",
          transport_type: :streamable,
          request_timeout: 15000, # Optional: timeout in milliseconds (default: 8000)
          config: {
            url: ENV["GEORESEARCH_MCP_SERVER_URL"],
            headers: {}
          }
        )

        chat = RubyLLM.chat(model: RubyLLM.config.default_model)
          .with_instructions(INSTRUCTIONS)
          .with_schema(SCHEMA)
          .with_temperature(0.0)
          .with_tools(*geo_mcp.tools)

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
