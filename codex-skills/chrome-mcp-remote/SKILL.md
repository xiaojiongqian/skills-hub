---
name: chrome-mcp-remote
description: Use Chrome DevTools MCP via a manually launched Chrome (remote debugging). Use when Chrome MCP is unstable after macOS upgrades or when you need a reliable, fast MCP connection.
metadata:
  short-description: Chrome MCP remote-debug workflow
---

# Chrome MCP Remote-Debug Skill

Use this skill to run Chrome DevTools MCP by connecting to a manually launched Chrome instance.
This avoids macOS sandbox/permission issues and user-data-dir lock problems.

## Quick Start

1) Start the dedicated Chrome instance:

```
bash ~/.codex/skills/chrome-mcp-remote/scripts/start-chrome-mcp.sh
```

2) Ensure Codex MCP points to the same port (default 9223). The global config should use:

```
--browserUrl http://127.0.0.1:9223
```

3) Use Chrome MCP tools normally. If a page needs login, log in manually in the MCP Chrome window.

## Environment knobs

The script supports overrides:

- `CHROME_MCP_PORT` (default 9223)
- `CHROME_MCP_PROFILE` (default /tmp/chrome-devtools-mcp-profile)
- `CHROME_MCP_CHROME` (default /Applications/Google Chrome.app/Contents/MacOS/Google Chrome)

Example:

```
CHROME_MCP_PORT=9333 CHROME_MCP_PROFILE=/tmp/mcp-profile bash ~/.codex/skills/chrome-mcp-remote/scripts/start-chrome-mcp.sh
```

If you change the port, update Codex MCP args to match.

## Login guidance

For sites requiring authentication:

- Prefer manual login in the MCP Chrome window. Cookies are stored in the dedicated profile dir.
- If you must have Codex fill credentials, provide them explicitly for this session only; do not store secrets in files.

## Troubleshooting (fast checks)

- Verify remote debugging is up:

```
curl -s http://127.0.0.1:9223/json/version
```

- If empty or 404, ensure Chrome was started with the remote-debugging flags and a non-default user-data-dir.
