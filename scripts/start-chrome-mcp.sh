#!/usr/bin/env bash
set -euo pipefail

CHROME_MCP_PORT="${CHROME_MCP_PORT:-9223}"
CHROME_MCP_PROFILE="${CHROME_MCP_PROFILE:-$HOME/.claude/chrome-devtools-mcp-profile}"
CHROME_MCP_CHROME="${CHROME_MCP_CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
CHROME_MCP_LOG="${CHROME_MCP_LOG:-$HOME/.claude/chrome-devtools-mcp.log}"

if [[ ! -x "$CHROME_MCP_CHROME" ]]; then
  echo "Chrome binary not found or not executable: $CHROME_MCP_CHROME" >&2
  exit 1
fi

mkdir -p "$CHROME_MCP_PROFILE"
mkdir -p "$(dirname "$CHROME_MCP_LOG")"

nohup "$CHROME_MCP_CHROME" \
  --remote-debugging-port="$CHROME_MCP_PORT" \
  --user-data-dir="$CHROME_MCP_PROFILE" \
  --no-first-run \
  --no-default-browser-check \
  --disable-extensions \
  >"$CHROME_MCP_LOG" 2>&1 &

echo "Started Chrome with remote debugging on :$CHROME_MCP_PORT"

action_url="http://127.0.0.1:${CHROME_MCP_PORT}/json/version"
for _ in {1..30}; do
  if curl -s --max-time 1 "$action_url" >/dev/null 2>&1; then
    echo "Chrome MCP is ready: $action_url"
    exit 0
  fi
  sleep 0.2
done

echo "Chrome remote debugging is not ready. Check log: $CHROME_MCP_LOG" >&2
exit 1
