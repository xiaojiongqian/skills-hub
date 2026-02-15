#!/usr/bin/env bash
set -euo pipefail

CHROME_MCP_PORT="${CHROME_MCP_PORT:-9223}"
CHROME_MCP_PROFILE="${CHROME_MCP_PROFILE:-/tmp/chrome-devtools-mcp-profile}"
CHROME_MCP_CHROME="${CHROME_MCP_CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

if [ ! -x "$CHROME_MCP_CHROME" ]; then
  echo "Chrome binary not found or not executable: $CHROME_MCP_CHROME" >&2
  exit 1
fi

mkdir -p "$CHROME_MCP_PROFILE"

nohup "$CHROME_MCP_CHROME" \
  --remote-debugging-port="$CHROME_MCP_PORT" \
  --user-data-dir="$CHROME_MCP_PROFILE" \
  --no-first-run \
  --no-default-browser-check \
  --disable-extensions \
  >/tmp/chrome-devtools-mcp.out 2>&1 &

echo "Started Chrome MCP instance"

for i in {1..20}; do
  if curl -s --max-time 1 "http://127.0.0.1:${CHROME_MCP_PORT}/json/version" >/dev/null 2>&1; then
    echo "Remote debugging ready on http://127.0.0.1:${CHROME_MCP_PORT}"
    exit 0
  fi
  sleep 0.2
done

echo "Remote debugging not ready. Check /tmp/chrome-devtools-mcp.out" >&2
exit 1
