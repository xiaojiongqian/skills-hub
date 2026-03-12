---
name: playwright-mcp
version: 1.0.0
license: MIT
description: Use Playwright MCP for browser automation and regression checks when Chrome DevTools MCP is unavailable, when you need cross-browser coverage (Chromium/Firefox/WebKit), or when scripted browser control is more reliable.
---

# Playwright MCP

Use this skill for browser automation, UI regression checks, data extraction, and response assertions with Playwright-based tools.

## Quick start
1. Ensure a Playwright MCP server is installed and enabled for the current agent.
2. Open the target page and wait for the first stable landmark before interacting.
3. Capture screenshots, console logs, and key network responses when diagnosing failures.

## Recommended workflow
1. Navigate and wait for a stable selector or visible text.
2. Perform the minimum interaction needed to reproduce or verify behavior.
3. Record evidence: screenshots, console errors, and relevant request/response data.
4. Report the exact failing step, reproduction path, and expected versus actual behavior.

## Notes
- Playwright supports Chromium, Firefox, and WebKit.
- Prefer `chrome-devtools-mcp` for fast single-browser debugging when it is already working.
- Use Playwright when deterministic scripted flows or broader browser coverage matter more.
