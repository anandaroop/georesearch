# frozen_string_literal: true

require "dry/cli"
require "json"

module Georesearch
  module CLI
    module Commands
      class Base < Dry::CLI::Command
        def call(*)
          Georesearch.configure_llm
        end

        private

        # Pretty print JSON data using jq if available, otherwise use Ruby's JSON formatter
        def pretty_json(data)
          has_jq = system("which jq > /dev/null 2>&1")
          io = has_jq ? IO.popen("jq .", "w") : $stdout
          io.puts JSON.pretty_generate(data)
          io.close if has_jq
        end

        # Pretty print CSV data using csvlook if available
        def pretty_csv(csv)
          has_csvlook = system("which csvlook > /dev/null 2>&1")
          io = has_csvlook ? IO.popen("csvlook --max-column-width 25", "w") : $stdout
          io.puts csv
          io.close if has_csvlook
        end
      end
    end
  end
end
