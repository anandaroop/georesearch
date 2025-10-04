# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :faff do
  require_relative "lib/georesearch/agents/analyzer"
  Georesearch::Agents::Analyzer.analyze
end

desc "Run StandardRB linter"
task :lint do
  sh "standardrb"
end

desc "Run StandardRB auto-fix"
task :fix do
  sh "standardrb --fix"
end

desc "Run tests and linter"
task default: [:spec, :lint]
