# frozen_string_literal: true

require "ruby_llm"
require_relative "georesearch/version"
require_relative "georesearch/cli"

module Georesearch
  class Error < StandardError; end

  def self.configure_llm
    RubyLLM.configure do |config|
      config.openai_api_key = ENV["GEORESEARCH_OPENAI_API_KEY"] || ENV["OPENAI_API_KEY"]
      config.anthropic_api_key = ENV["GEORESEARCH_ANTHROPIC_API_KEY"] || ENV["ANTHROPIC_API_KEY"]
      config.default_model = ENV["GEORESEARCH_DEFAULT_MODEL"] || "claude-sonnet-4"
    end
  end
end
