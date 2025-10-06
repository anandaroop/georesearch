# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "georesearch"
  spec.version = "0.3.0"
  spec.authors = ["Roop"]
  spec.email = ["roop@example.com"]

  spec.summary = "A command line application to perform research on toponyms"
  spec.description = "Perform research on toponyms and return data in a structured format useful for cartography projects"
  spec.homepage = "https://github.com/roop/georesearch"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/roop/georesearch"

  spec.files = Dir.glob("{lib,exe}/**/*") # + %w[README.md LICENSE.txt]
  spec.bindir = "exe"
  spec.executables = ["georesearch"]
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "ruby_llm", "~> 1.0"
  spec.add_dependency "ruby_llm-schema", "~> 0.2"
  spec.add_dependency "ruby_llm-mcp", "~> 0.6"
  spec.add_dependency "tty-spinner", "~> 0.9"
  spec.add_dependency "rainbow", "~> 3.1"

  spec.add_development_dependency "dotenv", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.0"
end
