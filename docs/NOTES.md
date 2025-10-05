# Notes

## Learnings

- **parallelize**
  - no reason to sit around waiting for a serial chain of research tool calls
  - fire several at once using a worker pool
  - but be nice
    - use limited concurrency e.g. 4 workers
    - throttle by sleeping for a bit after each request
- **render unto LLM** that which is unknown and fuzzy, and unto conventional code that which is known and deterministic
  - e.g.: serial number for each toponym
    - LLM does well enough, but it could goof, and it's easy enough to derive that on the deterministic side of the program
  - e.g. writing to file system
    - you can hand the LLM a "blank check" by using `@modelcontextprotocol/server-filesystem`
    - or you can control the file-writing logic deterministically
      (at least for a CLI which runs on your machine and has access to FS. Maybe for other kinds of clients MCP FS makes sense)

## Features/Strengths

- typical LLM-y stuff
  - handles typos, synonyms gracefully
  - resilient to context changes, e.g upstate ny vs ancient world (data/input/cities-{ny,ancient}.txt)
  - adapts messy human input to formal structured vocabularies, e.g. a context of "usa" or "the united states" gets propertly turned into the ISO-2 code in `country: "US"` search param
- easily works with a bundle of tools
  - the existing MCP server `anandaroop/geomcp` works just as well (better, actually) with this as with the fast-agent python framework
- abstractions that work well with CLI but are not limited to them:
  - `Analyzer` agent
  - `Search` agent
  - these could prob easily utilized by a web app
- flexible output format
  - earlier iteration gave

## Non-features/Weaknesses

- opaque spend, at the moment
- verbose debug output exists, but it's not fun to read

## TODOs

- [ ] Check out **prompt caching** https://www.anthropic.com/news/prompt-caching

  - cache frequently used context between API calls
  - provide Claude with more background knowledge and example outputs—all
  - reduce costs by up to 90% and latency by up to 85% for long prompts
  - writing to the cache costs _25% more than_ base input token price
  - using cached content costS _only 10% of_ base input token price

- [ ] Log each LLM call to a sqlite db, for pretty rendering traces later?

## If actually releasing this

- [ ] Make geonames user for MCP server configurable
- [ ] Remove me-specific messages like the MCP error in lib/georesearch/commands/find.rb
