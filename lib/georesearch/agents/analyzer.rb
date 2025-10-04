require "ruby_llm"

module Georesearch
  module Agents
    class Analyzer
      attr_reader :response

      def self.analyze
        pp new.response
      end

      def initialize
        @chat = RubyLLM.chat(model: "claude-sonnet-4")
        response = @chat.ask "What up dawg?"
        @response = response.content
      end
    end
  end
end
