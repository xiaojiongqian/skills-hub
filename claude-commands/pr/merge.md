---
name: PR: Merge
description: 调用 git-pr-merge skill 来 review、验证并合并一个 GitHub PR。支持 `/pr:merge <PR号或URL> [--target <branch>] [--delete] [--worktree]`。
category: PR
tags: [pr, merge, github, review]
---

# PR: Merge

这是 `git-pr-merge` 的 Claude command 包装层，不再维护独立的合并逻辑。

## 参数

- 第一个位置参数：PR 编号、`#123` 或 PR URL
- `--target <branch>`：目标分支，默认 `dev`
- `--delete`：成功合并后删除源分支
- `--worktree`：在临时 worktree 中执行，避免影响当前工作区

## 执行要求

1. 解析用户输入中的参数。
2. 调用 `git-pr-merge` skill，并将这些参数作为输入。
3. 按 skill 的完整流程执行 review、冲突处理、验证、合并、清理和报告。
4. 除非缺少必要输入或权限不足，否则不要为中间步骤停下来询问确认。

## 示例

```bash
/pr:merge 123
/pr:merge 123 --target main
/pr:merge 123 --delete --worktree
```
