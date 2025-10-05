# Notes

## Learnings

- LLM vs conventional
  - serial number for each toponym
    - LLM does well enough, but it could goof, and it's easy enough to derive that on the deterministic side of the program

## TODOs

- [ ] Check out **prompt caching** https://www.anthropic.com/news/prompt-caching

  - cache frequently used context between API calls
  - provide Claude with more background knowledge and example outputs—all
  - reduce costs by up to 90% and latency by up to 85% for long prompts
  - writing to the cache costs _25% more than_ base input token price
  - using cached content costS _only 10% of_ base input token price
