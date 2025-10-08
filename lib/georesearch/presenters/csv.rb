# frozen_string_literal: true

require "csv"

module Georesearch
  module Presenters
    class CSV
      def self.present(results)
        new(results).present
      end

      def initialize(results)
        @results = results
        @output = StringIO.new
        build!
      end

      def build!
        @output << headers.to_csv
        @results.each do |result|
          toponym, result = result.values_at("toponym", "result")
          result["matches"].each do |match|
            row = [
              toponym["index"],
              toponym["name"],
              match["name"],
              match["feature_type"],
              match["feature_code"],
              match["longitude"],
              match["latitude"],
              match["aliases"],
              match["hierarchy"],
              match["confidence"],
              match["source"],
              match["assistant_notes"]
            ]
            @output << row.to_csv
          end
        end
      end

      def headers
        [
          "#",
          "searched",
          "found",
          "feature_type",
          "feature_code",
          "longitude",
          "latitude",
          "aliases",
          "hierarchy",
          "confidence",
          "source",
          "assistant_notes"
        ]
      end

      def present
        @output.string
      end
    end
  end
end
