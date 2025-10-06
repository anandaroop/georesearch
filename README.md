# Georesearch

A command-line tool that uses LLM-powered agents to extract toponyms (place names) from text files and enrich them with geographic data suitable for cartography projects.

## Overview

Georesearch analyzes text documents to identify place names, then researches each toponym to find accurate geographic coordinates and contextual information. The results can be exported in multiple formats including CSV, JSON, and GeoJSON for use in mapping applications.

## Features

- **Intelligent toponym extraction** - Analyzes text files to identify place names using LLM agents
- **Geographic enrichment** - Looks up coordinates and contextual data for each place
- **Multiple output formats** - Export as CSV, JSON, or GeoJSON
- **Interactive preview** - Automatically opens results in geojson.io for visualization
- **Contextual disambiguation** - Uses surrounding text to identify the correct location when place names are ambiguous
- **Parallel processing** - Researches multiple places concurrently for faster results

## Installation

### Prerequisites

- Ruby 3.0 or higher (3.4.5 recommended)
- API keys for LLM providers (OpenAI or Anthropic)
- An MCP (Model Context Protocol) server for geographic lookups

### Install from source

```bash
git clone https://github.com/roop/georesearch.git
cd georesearch
bundle install
bundle exec rake install # installs on to your system
```

### Configuration

Set your API keys as environment variables:

```bash
# Supply a key for your chosen model (default: Anthropic Claude Sonnet 4)
export GEORESEARCH_ANTHROPIC_API_KEY="your-openai-key"
export GEORESEARCH_OPENAI_API_KEY="your-anthropic-key"

# Optional overrides

# Choose a model from https://rubyllm.com/available-models/
export GEORESEARCH_DEFAULT_MODEL="claude-sonnet-4"

# Specify parallelism
export GEORESEARCH_MAX_WORKERS=8

# Enable very verbose debugging output
export RUBYLLM_DEBUG=true
```

## Usage

### Research toponyms in a file

Analyze a file, extract all place names, and export geographic data:

```bash
georesearch research path/to/document.txt
```

By default, this creates timestamped CSV and GeoJSON files and opens a preview in geojson.io.

**Options:**

- `--format=csv,json,geojson,raw` - Specify output formats (default: csv,geojson)
- `--no-preview` - Skip opening geojson.io preview

### Search for a specific place

Look up geographic data for a single toponym:

```bash
georesearch search "Alexandria"
```

**Options:**

- `--category` - Specify type (e.g., "city", "river", "mountain")
- `--context` - Provide location context (e.g., "Egypt")
- `--note` - Add clarifying notes

Example:

```bash
georesearch search "Alexandria" --category=city --context=Egypt
```

### Analyze a file (no lookup)

Extract toponyms without performing geographic research:

```bash
georesearch analyze path/to/document.txt
```

### Version information

```bash
georesearch version
```

## Output Formats

- **CSV** - Tabular format with columns for name, category, coordinates, and context
- **JSON** - Structured data with detailed information about each toponym
- **GeoJSON** - Geographic format compatible with mapping libraries and GIS tools
- **Raw** - Unprocessed agent responses for debugging
