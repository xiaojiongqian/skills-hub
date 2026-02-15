---
name: chrome-mcp-remote
description: 通过手动启动 Chrome remote debugging 使用 Claude 的 chrome-devtools MCP。适用于 macOS 升级后连接不稳定、默认 Chrome MCP 无法连接、需要更快更稳定浏览器调试通道的场景。
tools: Bash
model: inherit
---

# Chrome MCP Remote

## Quick start
1. 启动专用 Chrome remote-debug 实例：
   - `bash ~/.claude/scripts/start-chrome-mcp.sh`
2. 确认 MCP 已配置为 `chrome-devtools` 且 `browserUrl` 指向 `http://127.0.0.1:9223`。
3. 在 MCP Chrome 窗口中手动登录需要认证的网站，再继续自动化操作。

## Useful checks
- `curl -s http://127.0.0.1:9223/json/version`
- 若失败，检查 `~/.claude/chrome-devtools-mcp.log`。

## Environment knobs
- `CHROME_MCP_PORT` (default `9223`)
- `CHROME_MCP_PROFILE` (default `~/.claude/chrome-devtools-mcp-profile`)
- `CHROME_MCP_CHROME` (default `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`)
