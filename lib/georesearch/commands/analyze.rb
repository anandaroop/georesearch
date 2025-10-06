# frozen_string_literal: true

require_relative "base"
require_relative "../agents/analyzer"
require "tty-spinner"

module Georesearch
  module CLI
    module Commands
      class Analyze < Base
        desc "Analyze a file and extract toponyms"

        argument :file, type: :string, required: true, desc: "Path to the file to analyze"

        def call(file:, **)
          super
          spinner = TTY::Spinner.new("[:spinner] Analyzing #{file}...", format: :dots)
          spinner.auto_spin
          file_path = File.expand_path(file)
          analysis = Georesearch::Agents::Analyzer.analyze(file: file_path)
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
