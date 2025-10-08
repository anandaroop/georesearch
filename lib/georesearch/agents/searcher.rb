# frozen_string_literal: true

require "ruby_llm"
require "ruby_llm/schema"
require "ruby_llm/mcp"

# monkeypatch, see https://github.com/patvice/ruby_llm-mcp/issues/65
module RubyLLM
  module MCP
    module Notifications
      class Initialize
        def call
          @coordinator.request(notification_body, add_id: true, wait_for_response: false)
        end
      end
    end
  end
end

module Georesearch
  module Agents
    class Searcher
      attr_reader :response, :usage

      SCHEMA = RubyLLM::Schema.create do
        array :matches, description: "Search result matches for the supplied toponym. Usually just one, but you may include multiple IF there is ambiguity" do
          object do
            string :name, description: "The name of the found toponym"
            string :feature_type, description: "The feature type of the matching toponym. Not a format feature class or feature code from GeoNames but something more human readable such as 'city', 'historical site', 'archaeological site', 'temple', 'river', 'mountain', 'desert', etc"
            string :feature_code, description: "The GeoNames feature code if available, e.g. 'PPLA' or 'ADM2'"
            number :longitude, description: "The decimal longitude of the matching toponym"
            number :latitude, description: "The decimal latitude of the matching toponym"
            string :aliases, description: "Alternate names for the toponym in a comma-separated list"
            string :hierarchy, description: "A geographical hierarchy describing the toponym's 'parentage', e.g. 'China > Zhejiang' for Hangzhou; or 'USA > Louisiana' for New Orleans"
            number :confidence, description: "A decimal number in the range 0.0 to 1.0 indicating how confident you are that this row represents the ACTUAL toponym the user is looking for"
            string :source, description: "Information that will attest to the source of truth for the result. Provide a URL if possible, e.g. for a GeoNames ID of 42 use 'https://www.geonames.org/42'. If no URL can be constructed provide a source and id, or whatever is available"
            string :assistant_notes, description: "Use sparingly, when something needs clarification, e.g. multiple matching results or ambiguous results"
          end
        end
      end

      INSTRUCTIONS = <<~INSTRUCTIONS
        You are a specialized cartography and geospatial researcher with deep knowledge of geospatial data sources.
        Your expertise spans historical geography, cartography, and toponymy.

        For modern names you prefer to search GeoNames for its highly structured data. But you also use Wikipedia as needed, esp for historical or obscure sites.

        When researching place names, you will:

        2. **Devise appropriate search terms**

        - Sometimes you will have extra notes that scope a toponym to a category or region
        - Only include that info in your search terms if it's likely to help
        - Otherwise prefer simpler terms and use the parenthetical info to assess confidence

        3. **Scope your research appropriately**

        - If you know the broad geographic scope of the project you shold constrain result sets to reduce the occurrence of ambiguously named results
        - Example: If the project appears to be focused on Asia
          - You MAY then use that information to e.g. supply `continent: 'AS` to GeoNames queries to constrain results
        - Example: If the project appears to be focused on Mexico
          - You MAY then use that information to e.g. supply `country: 'MX'` to GeoNames queries to constrain results

        4. **Point out ambiguous results**:

        - Constrain queries as suggested above to reduce ambiguous cases
        - When ambiguous cases remain, include them in your final results
        - Denote the ambiguous cases by including a brief note in the "assistant_notes" field of the result set

        5. **Provide results in a standard format**:

        - You must adhere to the provided schema
        - Follow the provided schema exactly, nothing more or less, no markdown, no codefence, no yapping.
        - Here is the schema:

        #{SCHEMA.new.to_json}
      INSTRUCTIONS

      def self.search(toponym, project_notes: nil)
        searcher = new(toponym: toponym, project_notes: project_notes)
        searcher.response
      end

      def self.check_connection
        url = URI(ENV["GEORESEARCH_MCP_SERVER_URL"])
        Net::HTTP.get_response(url)
      rescue Errno::ECONNREFUSED
        raise "Could not connect to MCP server at #{url}"
      end

      def initialize(toponym: nil, project_notes: nil)
        raise ArgumentError, "A valid toponym must be provided" if toponym.nil? || toponym["name"].to_s.strip.empty?

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

        prompt_parts = []
        prompt_parts << "Project notes: #{project_notes}" unless project_notes.to_s.strip.empty?
        prompt_parts << "Toponym to research: #{JSON.pretty_generate(toponym)}"
        prompt_parts << "Research that toponym and give me only valid JSON, no yapping"
        prompt = prompt_parts.join("\n\n")

        response = chat.ask(prompt)
        @response = response.content

        @usage = {
          timestamp: Time.now.utc.iso8601,
          caller: self.class.name,
          input: toponym["name"],
          model_id: response.model_id,
          input_tokens: response.input_tokens,
          output_tokens: response.output_tokens
        }
      end
    end
  end
end
