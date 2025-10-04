# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe "Georesearch CLI" do
  let(:exe_path) { File.expand_path("../exe/georesearch", __dir__) }

  describe "help command" do
    it "displays help message when run without arguments" do
      _, stderr, status = Open3.capture3(exe_path)

      expect(status.success?).to be false
      expect(stderr).to include("Commands:")
      expect(stderr).to include("georesearch")
    end

    it "displays help message with --help flag" do
      _, stderr, status = Open3.capture3(exe_path, "--help")

      expect(status.success?).to be false
      expect(stderr).to include("Commands:")
      expect(stderr).to include("georesearch")
    end
  end

  describe "version command" do
    it "displays version with version command" do
      stdout, _stderr, status = Open3.capture3(exe_path, "version")

      expect(status.success?).to be true
      expect(stdout.strip).to eq(Georesearch::VERSION)
    end

    it "displays version with --version flag" do
      stdout, _stderr, status = Open3.capture3(exe_path, "--version")

      expect(status.success?).to be true
      expect(stdout.strip).to eq(Georesearch::VERSION)
    end
  end
end
