# frozen_string_literal: true

module Georesearch
  module Presenters
    class JSON
      def self.present(results)
        new(results).present
      end

      def initialize(results)
        @results = results
        @output = StringIO.new
        @records = []
        build!
      end

      def build!
        @results.each do |result|
          toponym, result = result.values_at("toponym", "result")
          result["matches"].each do |match|
            record = {
              searched: toponym["name"],
              found: match["name"],
              feature_type: match["feature_type"],
              feature_code: match["feature_code"],
              longitude: match["longitude"],
              latitude: match["latitude"],
              aliases: match["aliases"],
              hierarchy: match["hierarchy"],
              confidence: match["confidence"],
              source: match["source"],
              assistant_notes: match["assistant_notes"]
            }
            @records << record
          end
        end
      end

      def present
        @records
      end
    end
  end
end
