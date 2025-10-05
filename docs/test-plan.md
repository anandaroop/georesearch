# Test Coverage Plan for Analyzer Agent and Analyze Command

## 1. Setup & Dependencies

- Add webmock gem to development dependencies for mocking HTTP calls
- Create spec/fixtures/ directory structure with test files:
- sample_with_toponyms.txt - File with known place names
- empty_file.txt - Empty test file
- no_toponyms.txt - File with no place names
- large_file.txt - File for testing size limits

## 2. Create Unit Tests: spec/georesearch/agents/analyzer_spec.rb

- Test valid file analysis with mocked LLM responses
- Test schema structure validation (summary + toponyms array)
- Test error handling (nil file, missing file, empty path)
- Test class method .analyze delegates correctly
- Mock RubyLLM to avoid real API calls in unit tests
- Test temperature is set to 0.0 for deterministic output

## 3. Create Unit Tests: spec/georesearch/commands/analyze_spec.rb

- Test command execution with valid --file option
- Test JSON output formatting
- Test file path expansion (relative to absolute)
- Test error propagation from Analyzer
- Test missing --file option handling
- Mock Analyzer.analyze to avoid dependencies

## 4. Enhance Integration Tests in spec/cli_spec.rb

- Add "analyze command" describe block
- Test full command execution with fixture files
- Test help text for analyze command
- Test error messages for invalid files
- Use environment variable to skip tests if API key missing

## 5. Testing Approach

- Unit tests will use mocks to isolate components
- Integration tests will use fixture files
- Add shared examples for common behaviors
- Use WebMock to prevent actual API calls in CI
- Add helper methods for creating test doubles

## 6. Refactoring Considerations

- No major refactoring needed in production code
- Consider extracting test helpers to spec/support/
- Follow existing RSpec patterns from cli_spec.rb
