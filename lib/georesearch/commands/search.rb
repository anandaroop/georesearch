# frozen_string_literal: true

require_relative "base"
require_relative "../agents/searcher"
require "tty-spinner"

module Georesearch
  module CLI
    module Commands
      class Search < Base
        desc "Locate a toponym and return structured data about it"
        argument :name, type: :string, required: true, desc: "Name of the toponym to search for"
        option :category, type: :string, desc: "Category of the toponym, e.g. 'city', 'river', 'mountain', 'archaeological site', etc."
        option :context, type: :string, desc: "Location context for the toponym, e.g. the state or country that contains it"
        option :note, type: :string, desc: "Any additional explanatory notes"

        def call(name:, category: nil, context: nil, note: nil)
          super
          spinner = TTY::Spinner.new("[:spinner] Searching for #{name}...", format: :dots)
          spinner.auto_spin
          response = Georesearch::Agents::Searcher.search({
            "name" => name,
            "category" => category,
            "context" => context,
            "note" => note
          })
          spinner.success("Done!")
          puts JSON.pretty_generate(response["matches"])
        rescue RubyLLM::MCP::Errors::TransportError => e
          spinner.error("Failed!")

          puts <<~EOS
            Looks like the MCP server is not running. Try:

            cd ~/src/me/geomcp && foreman run server
          EOS
        end
      end
    end
  end
end
