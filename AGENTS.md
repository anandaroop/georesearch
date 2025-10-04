# Georesearch

A command-line application to perform research on toponyms and return data in a structured format useful for cartography projects.

## Project Structure

This project follows standard Ruby gem conventions:

- `lib/` - Source code
- `exe/` - Executable binaries
- `spec/` - RSpec tests
- `docs/` - Documentation
- `docs/Stories/` - User stories and requirements

## Development Guidelines

### Language & Tools

- **Language**: Ruby 3.4.5 (managed via Mise-en-place)
- **Package**: Rubygem
- **Framework**: dry-cli
- **Linting**: StandardRB
- **Testing**: RSpec
- **Task Runner**: Rakefile

### Workflow

- **Commits**: Use Conventional Commits format (feat:, fix:, docs:, etc.)
- **Testing**: Run `bundle exec rake` to run tests and linter before committing
- **Stories**: User stories live in `docs/Stories/`, not in this file

### Available Rake Tasks

- `rake` - Default: runs tests and linter
- `rake spec` - Run RSpec tests only
- `rake lint` - Run StandardRB linter
- `rake fix` - Auto-fix StandardRB issues

### LLM Integration

- **Framework**: RubyLLM, RubyLLM::MCP
