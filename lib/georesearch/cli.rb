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

      class Base < Dry::CLI::Command
        def call(*)
          Georesearch.configure_llm
        end
      end

      class Faff < Base
        # desc "Sandbox for trying things out"

        def call(*)
          super
          require_relative "agents/analyzer"
          Georesearch::Agents::Analyzer.analyze
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "faff", Faff
    end
  end
end
