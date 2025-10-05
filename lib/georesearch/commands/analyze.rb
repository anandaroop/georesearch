# frozen_string_literal: true

require_relative "base"
require_relative "../agents/analyzer"

module Georesearch
  module CLI
    module Commands
      class Analyze < Base
        desc "Analyze a file and extract toponyms"

        option :file, type: :string, required: true, desc: "Path to the file to analyze"

        def call(file: nil, **)
          super
          file_path = File.expand_path(file)
          analysis = Georesearch::Agents::Analyzer.analyze(file: file_path)
          puts JSON.pretty_generate(analysis)
        end
      end
    end
  end
end
