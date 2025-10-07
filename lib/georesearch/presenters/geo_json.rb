# frozen_string_literal: true

module Georesearch
  module Presenters
    class GeoJSON
      def self.present(results)
        new(results).present
      end

      def initialize(results)
        @results = results
        @output = StringIO.new
        @feature_collection = {
          "type" => "FeatureCollection",
          "features" => []
        }
        build!
      end

      def build!
        @results.each do |result|
          toponym, result = result.values_at("toponym", "result")
          result["matches"].each do |match|
            feature = {
              "type" => "Feature",
              "geometry" => {
                "type" => "Point",
                "coordinates" => [match["longitude"], match["latitude"]]
              },
              "properties" => {
                "searched" => toponym["name"],
                "found" => match["name"],
                "feature_type" => match["feature_type"],
                "feature_code" => match["feature_code"],
                "aliases" => match["aliases"],
                "hierarchy" => match["hierarchy"],
                "confidence" => match["confidence"],
                "source" => match["source"],
                "assistant_notes" => match["assistant_notes"]
              }
            }
            @feature_collection["features"] << feature
          end
        end
      end

      def present
        @feature_collection
      end
    end
  end
end
