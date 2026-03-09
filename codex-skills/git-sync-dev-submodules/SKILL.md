---
name: git-sync-dev-submodules
description: >
  Fast local dev sync for Git worktrees with optional submodule refresh. Use
  when Codex needs to (1) update the current worktree branch onto the latest
  `origin/dev`, or (2) when run from a `dev` worktree, fast-forward `dev` and
  rebase every other clean worktree onto local `dev`. Refresh `func-core` by
  default and support `--skip-submodules` when submodules should be ignored.
---

# Git Sync Dev Submodules

## Overview
- Keep the flow local-first and fast: fetch once, then sync branches with `merge --ff-only` or `rebase`.
- Default to refreshing `func-core` after branch sync.
- After refresh, attach each selected submodule to the superproject's current branch name at the pinned commit when the superproject is on a branch.
- Use `--skip-submodules` to skip submodule refresh entirely.
- Use `--dry-run` to preview actions before changing git state.

## Scripts
- `scripts/sync-dev-to-current-branch.sh`
  - Run in any non-detached worktree.
  - If current branch is `dev`, fast-forward it to `origin/dev`.
  - Otherwise, rebase the current branch onto `origin/dev`.
- `scripts/sync-dev-worktrees.sh`
  - Run from a `dev` worktree.
  - Fast-forward the current `dev` worktree to `origin/dev`.
  - Rebase every other clean, non-detached worktree onto local `dev`.

## Defaults
- Remote: `origin`
- Dev source branch: `dev`
- Submodules: `func-core`

## Options
- `--remote <name>`: remote name to fetch from (default `origin`)
- `--dev-branch <name>`: source branch to sync against (default `dev`)
- `--submodules <list|all>`: comma-separated submodule paths, or `all` (default `func-core`)
- `--skip-submodules`: do not refresh submodules
- `--dry-run`: print the plan without changing git state
- `--help`: print usage

## Inspect Pinned SHA
- Current checkout: `git ls-tree HEAD func-core | awk '{print $3}'`
- Specific branch: `git ls-tree <branch> func-core | awk '{print $3}'`
- Compare pinned vs current submodule HEAD: `printf 'pinned: '; git ls-tree HEAD func-core | awk '{print $3}'; printf 'actual: '; git -C func-core rev-parse HEAD`

## Common Commands
```bash
# Sync only the current worktree and refresh func-core
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh

# Sync every worktree from a dev worktree and refresh func-core
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-worktrees.sh

# Sync every worktree but skip submodules
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-worktrees.sh --skip-submodules

# Preview the current-worktree sync without changing git state
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --dry-run
```

## Reporting
- Report updated worktrees.
- Report skipped detached or dirty worktrees.
- Report failures after aborting a conflicted batch rebase.
- Report when a submodule branch is aligned to the superproject branch name at the pinned commit.
