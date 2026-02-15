#!/usr/bin/env bash
set -euo pipefail

scope="user"
chrome_port="${CHROME_MCP_PORT:-9223}"
playwright_pkg="${PLAYWRIGHT_MCP_PACKAGE:-@playwright/mcp}"
skip_playwright_browser=false
download_only=false
configure_only=false

usage() {
  cat <<USAGE
Usage: scripts/install-claude-mcp.sh [options]

Install/download Playwright + Chrome MCP packages and register them in Claude.

Options:
  --scope <local|user|project>  Claude MCP scope (default: user)
  --chrome-port <port>          Chrome remote-debugging port (default: 9223)
  --playwright-pkg <name>       Playwright MCP npm package (default: @playwright/mcp)
  --skip-playwright-browser     Skip chromium download via playwright install
  --download-only               Only download packages, do not configure Claude MCP
  --configure-only              Only configure Claude MCP, skip package download
  -h, --help                    Show help
USAGE
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

validate_scope() {
  case "$scope" in
    local|user|project)
      ;;
    *)
      echo "Invalid scope: $scope (expected: local|user|project)" >&2
      exit 1
      ;;
  esac
}

upsert_mcp() {
  local name="$1"
  shift

  if claude mcp get "$name" >/dev/null 2>&1; then
    claude mcp remove "$name" >/dev/null
  fi

  claude mcp add --scope "$scope" --transport stdio "$name" -- "$@"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      scope="$2"
      shift
      ;;
    --chrome-port)
      chrome_port="$2"
      shift
      ;;
    --playwright-pkg)
      playwright_pkg="$2"
      shift
      ;;
    --skip-playwright-browser)
      skip_playwright_browser=true
      ;;
    --download-only)
      download_only=true
      ;;
    --configure-only)
      configure_only=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$download_only" == "true" && "$configure_only" == "true" ]]; then
  echo "Cannot use --download-only and --configure-only together." >&2
  exit 1
fi

validate_scope
require_cmd node
require_cmd npm
require_cmd npx
require_cmd claude

if [[ "$configure_only" == "false" ]]; then
  echo "[1/2] Downloading MCP packages via npx cache..."
  npx -y "$playwright_pkg" --help >/dev/null
  npx -y chrome-devtools-mcp --help >/dev/null

  if [[ "$skip_playwright_browser" == "false" ]]; then
    echo "[1/2] Downloading Playwright Chromium browser..."
    npx -y playwright install chromium >/dev/null
  fi
fi

if [[ "$download_only" == "false" ]]; then
  echo "[2/2] Registering MCP servers in Claude (scope=$scope)..."

  upsert_mcp "playwright-mcp" npx -y "$playwright_pkg"
  upsert_mcp "chrome-devtools" npx -y chrome-devtools-mcp --browserUrl "http://127.0.0.1:${chrome_port}" --no-usage-statistics

  echo "Configured MCP servers:"
  claude mcp list
fi

echo "Done."
echo "If Chrome MCP fails to connect, run: bash ~/.claude/scripts/start-chrome-mcp.sh"
