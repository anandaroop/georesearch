# frozen_string_literal: true

require_relative "base"

module Georesearch
  module CLI
    module Commands
      class Faff < Base
        desc "Sandbox for trying things out"

        def call(file: nil, **)
          super
        end
      end
    end
  end
end
