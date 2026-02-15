#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repository." >&2
  exit 1
fi

cd "$repo_root"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" == "HEAD" ]]; then
  echo "Detached HEAD is not allowed for auto-dev." >&2
  exit 1
fi

if [[ "$current_branch" == "dev" || "$current_branch" == "main" ]]; then
  echo "Refusing to operate on protected branch: $current_branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Warning: working tree is dirty; deploy uses remote branch only." >&2
fi

printf 'AUTO_DEV_REPO_ROOT=%q\n' "$repo_root"
printf 'AUTO_DEV_BRANCH=%q\n' "$current_branch"

chrome_mcp_port="${AUTO_DEV_CHROME_MCP_PORT:-9223}"
chrome_mcp_ready=0
if curl -s --max-time 1 "http://127.0.0.1:${chrome_mcp_port}/json/version" >/dev/null 2>&1; then
  chrome_mcp_ready=1
else
  echo "Note: Chrome MCP remote debugging not detected on :${chrome_mcp_port}." >&2
fi

printf 'AUTO_DEV_CHROME_MCP_PORT=%q\n' "$chrome_mcp_port"
printf 'AUTO_DEV_CHROME_MCP_READY=%q\n' "$chrome_mcp_ready"
