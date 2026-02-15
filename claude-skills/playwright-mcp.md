---
name: playwright-mcp
description: 使用 Playwright MCP 进行浏览器自动化与回归验证。适用于 chrome-devtools MCP 不可用、需要跨浏览器验证（Chromium/Firefox/WebKit）或需要更稳定脚本化交互的场景。
tools: Bash
model: inherit
---

# Playwright MCP

## Quick start
1. 确认 MCP 已安装配置：
   - `bash ~/.claude/scripts/install-claude-mcp.sh --scope user`
2. 在 Claude 中使用 `playwright-mcp` 工具进行页面访问、点击、填表、截图、网络响应断言。

## Recommended flow
1. 导航到页面并等待关键元素出现。
2. 执行最小必要交互（点击/输入/提交）。
3. 捕获截图、控制台日志和关键请求结果。
4. 输出失败步骤、复现路径和修复建议。

## Notes
- Playwright 支持 Chromium/Firefox/WebKit。
- 如果只需高性能单浏览器调试，优先使用 `chrome-devtools`。
