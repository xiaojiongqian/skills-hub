---
name: git-sync-dev-submodules
description: >
  Simplified sync for current branch and selected submodules. Verify the
  current branch has already been merged into `origin/dev`, rebase onto
  `origin/dev`, then push. Apply the same check/rebase/push flow to submodules
  (default `func-core`).
---

# Git Sync Dev Submodules

## Overview
- This skill is now **rebase-first and merge-gated**.
- It only syncs when your current branch content is already merged into `origin/dev`.
- If branch content is not merged into `origin/dev`, it stops and asks you to merge to `dev` first.
- After superproject sync, it applies the same logic to selected submodules and pushes them.

## Workflow
1. Confirm you are inside the target worktree and on the intended branch.
2. Script checks whether current branch is already merged into `origin/dev`.
3. If yes, rebase current branch onto `origin/dev` and push.
4. Run the same merged-check + rebase + push flow for selected submodules.

## Script
- Path: `scripts/sync-dev-to-current-branch.sh`
- Defaults:
  - Remote: `origin`
  - Dev source branch: `dev`
  - Submodules: `func-core`
- Safety:
  - Stop if superproject has uncommitted changes.
  - Stop if selected submodule has uncommitted changes.
  - Stop if current branch is not yet merged into `origin/dev`.
  - Stop if selected submodule branch is not yet merged into `origin/dev`.
  - Validate final alignment (`origin/dev...HEAD`) in summary.

## Common Commands
```bash
# Default: verify merged -> rebase -> push (superproject + func-core)
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh

# Sync all submodules defined in .gitmodules
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --submodules all

# Override remote or dev source branch
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --remote origin --dev-branch dev

# Skip submodule sync (main repo only)
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --skip-submodules
```

## Options
- `--remote <name>`: remote name to fetch/push (default `origin`)
- `--dev-branch <name>`: source branch to rebase onto (default `dev`)
- `--submodules <list|all>`: comma-separated submodule paths, or `all` (default `func-core`)
- `--skip-submodules`: do not process any submodule
- `--help`: print usage

## Reporting
- Report:
  - current branch name
  - superproject head commit after sync
  - superproject dev alignment count (`origin/dev...HEAD`)
  - each synced submodule and target branch
  - each synced submodule dev alignment count (`origin/dev...HEAD`)
  - whether pushes succeeded
