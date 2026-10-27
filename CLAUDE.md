# CLAUDE.md -- mrjonesbot.com

Shared instructions (core principles, workflow, dev standards, commands) live in `~/.claude/CLAUDE.md`.
This file contains only mrjonesbot.com specific context.

## Fly.io

App: `mrjonesbot-com` (`fly.toml`).

- **Use the flyctl MCP server** (`mcp__flyctl__*`, registered at user scope as `flyctl` → `fly mcp server`) to inspect Fly: `fly-status`, `fly-logs`, `fly-apps-releases`, `fly-machine-list`/`fly-machine-status`, `fly-secrets-list`, `fly-volumes-list`, `fly-certs-*`. Always pass the app name explicitly so you hit the right app.
- Check production logs with `fly-logs` when an error report points at prod, not dev.
- Anything that changes production (`fly-secrets-set`/`-unset`, `fly-machine-*` start/stop/restart/destroy/update, `fly-volumes-*` create/destroy/extend, `fly-apps-restart`) needs Nathan's confirmation first.
- The MCP has no deploy or interactive console; use the CLI for `fly deploy` and `fly ssh console`.
- If the tools fail with an expired-session error, ask Nathan to run `! fly auth login`.
