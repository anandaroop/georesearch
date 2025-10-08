# frozen_string_literal: true

require_relative "agents/analyzer"
require_relative "agents/searcher"

module Georesearch
  class Researcher
    attr_accessor :file
    attr_accessor :summary
    attr_accessor :short_summary
    attr_accessor :toponyms
    attr_accessor :num_workers
    attr_accessor :queue
    attr_accessor :results
    attr_accessor :usage

    def initialize(file:)
      @file = file
      @queue = Queue.new
      @results = []
      @num_workers = (ENV["GEORESEARCH_MAX_WORKERS"] || 4).to_i
      @usage = []
    end

    def prepare!
      analyzer = Georesearch::Agents::Analyzer.new(file: @file)
      @usage << analyzer.usage
      analysis = analyzer.response
      @summary = analysis["summary"]
      @short_summary = analysis["short_summary"]
      @toponyms = analysis["toponyms"]
      @toponyms.each_with_index do |toponym, index|
        @queue << {**toponym, "index" => index + 1}
      end
    end

    def work!(
      on_toponym_start: nil,
      on_toponym_done: nil
    )
      workers = @num_workers.times.map do
        Thread.new do
          loop do
            toponym = @queue.pop(true)
            on_toponym_start&.call(toponym, @toponyms.size)

            result = begin
              searcher = Georesearch::Agents::Searcher.new(toponym: toponym, project_notes: @summary)
              @usage << searcher.usage
              searcher.response
            rescue => e
              puts "Error researching #{toponym["name"]}: #{e.message}"
              File.open("error.log", "a") do |f|
                f.puts("#{Time.now} - Error researching #{toponym["name"]}: #{e.message}")
                f.puts(e.backtrace.join("\n"))
              end
              {"matches" => [{
                "name" => toponym["name"],
                "latitude" => 0.0,
                "longitude" => 0.0,
                "feature_code" => "ERR",
                "assistant_notes" => e.message
              }]}
            end

            @results << {
              "toponym" => toponym,
              "result" => result
            }

            on_toponym_done&.call(toponym, @toponyms.size, result, searcher&.usage)
            sleep(rand(0.5..1.5)) # throttle
          rescue ThreadError # queue empty
            break
          end
        end
      end

      workers.each(&:join)
    end
  end
end
