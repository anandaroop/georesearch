# frozen_string_literal: true

require_relative "base"
require_relative("../researcher")
require "tty-spinner"
require "rainbow"
require "rainbow/refinement"
using Rainbow

module Georesearch
  module CLI
    module Commands
      class Research < Base
        desc "Analyze a file for toponyms and locate them"

        argument :file, type: :string, required: true, desc: "Path to the file to analyze"

        def call(file:, **)
          super
          researcher = Researcher.new(file: file)

          analyze_spinner = TTY::Spinner.new("[:spinner] Analyzing", format: :dots)
          analyze_spinner.auto_spin

          # prepare the analysis
          researcher.prepare!

          analyze_spinner.success("(Found #{researcher.toponyms.count} toponyms — #{researcher.short_summary})".green)
          parent_spinner = TTY::Spinner::Multi.new("[:spinner] Researching #{file}".bright, format: :dots)
          spinners = {}

          # do the research work
          researcher.work!(
            on_toponym_start: ->(toponym, total) {
              spinner = parent_spinner.register("[:spinner] #{toponym["name"]}", format: :dots)
              spinner.auto_spin
              spinners[toponym["index"]] = spinner
            },
            on_toponym_done: ->(toponym, total, result) {
              matches = result["matches"]
              msg = if matches.length == 1
                lng, lat = matches[0].values_at("longitude", "latitude")
                "(#{lng.round(3)}, #{lat.round(3)})".green
              else
                "(#{matches.length} matches)".faint
              end
              spinners[toponym["index"]].success(msg)
            }
          )

          parent_spinner.success
          pretty_json(researcher.results)
        rescue => e
          puts e.message
          parent_spinner.error("Failed!")
        end
      end
    end
  end
end
