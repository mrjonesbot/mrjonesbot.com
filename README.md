# mrjonesbot.com

Personal website for Nathan Jones — developer and founder.

The site features an **interactive AI chat** powered by Claude that can answer in-depth questions about my career, experience, technical expertise, and working style. Think of it as a conversational resume — recruiters, hiring managers, or anyone curious can ask questions and get detailed, contextual answers in real time.

## AI Chat

The chat is backed by Anthropic's Claude API via the [ruby_llm](https://github.com/crmne/ruby_llm) gem. A career context file (`config/career_context.yml`) provides Claude with detailed knowledge about my background, and responses stream back to the browser in real time via Turbo Streams.

- Session-based conversation history
- Suggested questions to get started
- Rate limited to prevent abuse

## Tech Stack

- Ruby on Rails 8
- SQLite3
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Docker + Fly.io for deployment

## Setup

```bash
bundle install
bin/rails db:setup
bin/dev
```

Requires an `ANTHROPIC_API_KEY` environment variable for the AI chat feature.
