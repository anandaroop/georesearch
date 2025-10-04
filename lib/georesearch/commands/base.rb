# frozen_string_literal: true

require "dry/cli"

module Georesearch
  module CLI
    module Commands
      class Base < Dry::CLI::Command
        def call(*)
          Georesearch.configure_llm
        end
      end
    end
  end
end
