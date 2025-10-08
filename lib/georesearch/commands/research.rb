# frozen_string_literal: true

require_relative "base"
require_relative("../researcher")
require_relative("../presenters/csv")
require_relative("../presenters/json")
require_relative("../presenters/geo_json")
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
        option :format, type: :array, default: ["geojson", "csv"], desc: "Output formats"
        option :preview, type: :boolean, default: true, desc: "Preview GeoJSON output in geojson.io"

        def call(file:, format:, preview:, **)
          super
          Georesearch::Agents::Searcher.check_connection
          research(file: file)
          write(file: file, format: format, preview: preview)
        rescue => e
          puts e.message
        end

        private

        def research(file:)
          # puts "\nResearching #{file}".bright
          @researcher = Researcher.new(file: file)

          analyze_spinner = TTY::Spinner.new("[:spinner] Analyzing", format: :dots)
          analyze_spinner.auto_spin

          # prepare the analysis
          @researcher.prepare!

          msg = "(Found #{@researcher.toponyms.count} toponyms — #{@researcher.short_summary})".green
          usage = @researcher.usage.last
          msg += [" ↑ ", usage[:input_tokens].to_s.faint, " ↓ ", usage[:output_tokens].to_s.faint].join if usage
          analyze_spinner.success(msg)

          parent_spinner = TTY::Spinner::Multi.new("[:spinner] Researching".bright, format: :dots)
          spinners = {}

          # do the research work
          @researcher.work!(
            on_toponym_start: ->(toponym, total) {
              spinner = parent_spinner.register("[:spinner] #{toponym["name"]}", format: :dots)
              spinner.auto_spin
              spinners[toponym["index"]] = spinner
            },
            on_toponym_done: ->(toponym, total, result, usage) {
              matches = result["matches"]
              msg = if matches.length == 1
                lng, lat = matches[0].values_at("longitude", "latitude")
                "(#{lng.round(3)}, #{lat.round(3)})".green
              else
                "(#{matches.length} matches)".faint
              end
              msg += [" ↑ ", usage[:input_tokens].to_s.faint, " ↓ ", usage[:output_tokens].to_s.faint].join if usage
              spinners[toponym["index"]].success(msg)
            }
          )
          @researcher.results.sort_by! { |r| r["toponym"]["index"] }
          parent_spinner.success
        end

        def write(file:, format:, preview:)
          basename = File.basename(file, ".*")
          prefix = "toponyms-#{basename}-#{Time.now.strftime("%Y%m%d-%H%M%S")}"

          format.each do |fmt|
            case fmt
            when "raw"
              pretty_json(@researcher.results)
              filename = "#{prefix}-raw.json"
              File.write(filename, @researcher.results)
              puts "\nWrote #{filename}\n".cyan.bright
            when "csv"
              csv = Georesearch::Presenters::CSV.present(@researcher.results)
              pretty_csv(csv)
              filename = "#{prefix}.csv"
              File.write(filename, csv)
              puts "\nWrote #{filename}\n".cyan.bright
            when "json"
              json = Georesearch::Presenters::JSON.present(@researcher.results)
              pretty_json(json)
              filename = "#{prefix}.json"
              File.write(filename, JSON.pretty_generate(json))
              puts "\nWrote #{filename}\n".cyan.bright
            when "geojson"
              geojson = Georesearch::Presenters::GeoJSON.present(@researcher.results)
              pretty_json(geojson)
              filename = "#{prefix}.geojson"
              File.write(filename, JSON.pretty_generate(geojson))
              puts "\nWrote #{filename}\n".cyan.bright
              # preview
              encoded_geojson = CGI.escape(geojson.to_json)
              url = "http://geojson.io/#data=data:application/json,#{encoded_geojson}"
              system("open", url) if preview
            end
          end
        end
      end
    end
  end
end
