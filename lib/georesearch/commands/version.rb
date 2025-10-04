# frozen_string_literal: true

require "dry/cli"

module Georesearch
  module CLI
    module Commands
      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Georesearch::VERSION
        end
      end
    end
  end
end
