# frozen_string_literal: true

require "dry/cli"
require_relative "commands/version"
require_relative "commands/base"
require_relative "commands/faff"

module Georesearch
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "faff", Faff
    end
  end
end
