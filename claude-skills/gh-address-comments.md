---
name: gh-address-comments
description: 使用 gh CLI 处理当前分支对应 PR 的 review/issue comments。适用于用户要求“处理评论、修复 review 意见、逐条回复 PR 评论”等场景。
tools: Read, Write, Edit, Bash, Grep, Glob, TodoWrite
model: inherit
---

# GH Address Comments

## Prereq
- 先确认 `gh` 已登录：`gh auth status`
- 未登录时先让用户执行：`gh auth login`

## Workflow
1. 找到当前分支 PR：`gh pr view --json number,url,title`
2. 拉取评论线程：`bash ~/.claude/scripts/gh-fetch-comments.sh`
3. 给评论编号并总结每条需要的改动。
4. 让用户选择要处理的编号。
5. 实施修改并运行最小验证。
6. 用 `gh pr comment` 或 `gh pr review` 回传处理结果。

## Notes
- 优先修复高优先级、可复现、可验证的问题。
- 若评论冲突或上下文不足，先询问边界再改代码。
