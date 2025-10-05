# frozen_string_literal: true

require "ruby_llm"
require "ruby_llm/schema"

module Georesearch
  module Agents
    class Analyzer
      attr_reader :response

      SCHEMA = RubyLLM::Schema.create do
        string :summary, description: "A concise summary of the project, either provided explicitly or inferred from the file content"
        array :toponyms do
          object do
            string :name, description: "The toponym itself"
            string :category, description: "The category of the toponym, e.g. 'city', 'river', 'mountain', 'archaeological site', etc."
            string :context, description: "The location context for the toponym only if it was provided in the source text, e.g. the state or country that contains it"
            string :note, description: "Any additional explanatory notes provided in the text"
          end
        end
      end

      INSTRUCTIONS = <<~INSTRUCTIONS
        You are a research analyst with the ability to examine files and organize their
        content into a structured format that is suitable for passing on to a research agent.

        Your response should follow the provided schema exactly,
        nothing more or less, no markdown, no codefence, no yapping.

        Here is the schema:

        #{SCHEMA.new.to_json}
      INSTRUCTIONS

      def self.analyze(file: nil)
        analyzer = new(file: file)
        analyzer.response
      end

      def initialize(file: nil)
        raise ArgumentError, "A valid file path must be provided" if file.nil? || !File.exist?(file)

        chat = RubyLLM.chat(model: "claude-sonnet-4")
          .with_instructions(INSTRUCTIONS)
          .with_schema(SCHEMA)
          .with_temperature(0.0)

        response = chat.ask "Analyze this file", with: file
        @response = response.content
      end
    end
  end
end
