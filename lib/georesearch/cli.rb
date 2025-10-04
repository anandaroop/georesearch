# frozen_string_literal: true

require "dry/cli"

module Georesearch
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Georesearch::VERSION
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
    end
  end
end
