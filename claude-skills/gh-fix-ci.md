---
name: gh-fix-ci
description: 使用 gh CLI 检查 PR 的 GitHub Actions 失败项，提取日志并定位根因，先给修复计划再实施。适用于“修 CI、看 Actions 失败原因、修 PR checks”场景。
tools: Read, Write, Edit, Bash, Grep, Glob, TodoWrite
model: inherit
---

# GH Fix CI

## Prereq
- 确认 gh 登录：`gh auth status`
- 未登录时先执行：`gh auth login`

## Workflow
1. 解析目标 PR（默认当前分支 PR）。
2. 拉取 check 状态与日志：
   - `bash ~/.claude/scripts/gh-inspect-pr-checks.sh --repo . --pr <number-or-url>`
3. 归纳失败上下文：失败 job、关键报错片段、run URL。
4. 对用户先给最小可执行修复计划。
5. 用户确认后再改代码并验证。
6. 修复后建议复跑相关 tests/checks 并再次核验 `gh pr checks`。

## Scope rule
- 仅处理 GitHub Actions。
- 对外部 CI（如 Buildkite）仅报告 details URL，并标注 out of scope。
