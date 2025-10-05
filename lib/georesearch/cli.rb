# frozen_string_literal: true

require "dry/cli"
require_relative "commands/version"
require_relative "commands/base"
require_relative "commands/analyze"
require_relative "commands/search"
require_relative "commands/faff"

module Georesearch
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "faff", Faff, hidden: true
      register "version", Version, aliases: ["v", "-v", "--version"]
      register "analyze", Analyze
      register "search", Search, aliases: ["s", "find", "f"]
    end
  end
end
