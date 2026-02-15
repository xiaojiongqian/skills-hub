---
name: auto-dev
description: 在当前 worktree 中进行自主开发与调试，严格遵守 Git 分支安全约束。用户说“go auto-dev”或要求开始 auto-dev 时触发。适用于编码、测试、MCP 自动化（Chrome/Playwright）、Firebase/GCP 排障、GitHub Actions 开发环境部署。仅允许在当前分支提交/推送，禁止操作 dev/main。
tools: Read, Write, Edit, Bash, Grep, Glob, TodoWrite
model: inherit
---

# Auto Dev

## Guardrails (must follow)
- 用 `pwd` 和 `git rev-parse --show-toplevel` 确认当前仓库范围，只在当前 worktree 内操作。
- 用 `git rev-parse --abbrev-ref HEAD` 读取当前分支。
- 如果分支是 `dev` 或 `main`，立即停止并要求用户先切换到功能分支。
- 禁止 checkout/merge/rebase/push `dev` 或 `main`。
- 禁止推送到与当前分支不同的远端分支。
- 禁止 force-push 或改写远端历史。

## Secure context input
- 需要账号、token、session 时，向用户索取“当次会话值”。
- 不把敏感信息写入仓库文件、日志或 commit。

## Workflow
1. 先创建 TodoWrite 任务并保持状态同步。
2. 最小改动实现需求，优先复用现有脚本和已有能力。
3. 对改动运行最小充分验证（lint/test/build 或定向检查）。
4. 如果涉及部署，先确保当前分支与上游关联，再触发 dev workflow。
5. 输出结果时给出变更摘要、执行过的命令和验证结论。

## Helper scripts (recommended)
- `~/.claude/scripts/auto-dev-preflight.sh`
  - 检查 repo/branch 安全性，输出 `AUTO_DEV_REPO_ROOT`、`AUTO_DEV_BRANCH`、`AUTO_DEV_CHROME_MCP_READY`。
- `~/.claude/scripts/auto-dev-deploy-dev.sh --wait`
  - 根据变更自动推导部署参数并触发 `dev.yml`（当前分支）。

## Browser MCP preference
- 默认优先 `chrome-devtools`（快且稳定）。
- 如果 Chrome MCP 未就绪，先运行：
  - `bash ~/.claude/scripts/start-chrome-mcp.sh`
- 如果 Chrome MCP 不可用，再回退 `playwright-mcp`。

## Related Claude skills
- `firebase-gcp-debug`：Firebase/GCP 排障。
- `gh-address-comments`：处理 PR review comments。
- `gh-fix-ci`：定位并修复 GitHub Actions 失败检查。
- `chrome-mcp-remote` / `playwright-mcp`：浏览器自动化与页面调试。
