# frozen_string_literal: true

require_relative "base"
require_relative "../agents/bboxer"
require "tty-spinner"

module Georesearch
  module CLI
    module Commands
      class BBox < Base
        desc "Find the bounding box for a place"

        argument :place, type: :string, required: true, desc: "The place to find the bounding box for"

        def call(place:, **)
          super
          spinner = TTY::Spinner.new("[:spinner] Finding bounding box for #{place}...", format: :dots)
          spinner.auto_spin
          analysis = Georesearch::Agents::BBoxer.search(place: place)
          spinner.success("Done!")
          pretty_json(analysis)
        rescue => e
          puts e.message
          spinner.error("Failed!")
        end
      end
    end
  end
end
