---
name: git-sync-dev-submodules
description: Sync `origin/dev` into the current local branch in the current worktree, then push that branch to remote. Also sync and push submodule branches (default `func-core`) from `origin/dev` to the same branch name. Default behavior uses merge sync when branches diverge to guarantee true alignment (both superproject and selected submodules contain `origin/dev`), with `ff-only` available as an opt-in strict mode.
---

# Git Sync Dev Submodules

## Overview
- Run the bundled script to align the current branch with `origin/dev`, sync selected submodules from `origin/dev` to the same branch name, and push all updated branches.
- Default mode is `merge` for true alignment when branches diverge; use `ff-only` only when you explicitly want strict fast-forward behavior.
- Use this for repetitive "sync dev -> current branch + submodule + push" operations across different worktrees.

## Workflow
1. Confirm you are inside the target worktree and on the intended branch.
2. Run `scripts/sync-dev-to-current-branch.sh` from any path inside that repo.
3. Review the final summary and report the branch/commit results.

## Script
- Path: `scripts/sync-dev-to-current-branch.sh`
- Defaults:
  - Remote: `origin`
  - Dev source branch: `dev`
  - Sync mode: `merge`
  - Submodules: `func-core`
- Safety:
  - Stop if superproject has uncommitted changes.
  - Stop if selected submodule has uncommitted changes.
  - Enforce post-sync validation: superproject and each selected submodule must contain `origin/dev` (`behind=0`).
  - Auto-resolve superproject submodule-pointer conflicts during merge:
    - selected submodules: keep `ours` (then re-sync submodule branch and commit pointer)
    - unselected submodules: keep `theirs`
  - Submodule source-code merge conflicts are not auto-resolved; script stops for manual resolution.
  - Stop on non-submodule merge conflicts for manual resolution.

## Common Commands
```bash
# Default: sync current branch + func-core from origin/dev, then push
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh

# Strict fast-forward only (abort on divergence)
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --sync-mode ff-only

# Sync all submodules defined in .gitmodules
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --submodules all

# Override remote or dev source branch
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --remote origin --dev-branch dev

# Skip submodule sync (main repo only)
~/.codex/skills/git-sync-dev-submodules/scripts/sync-dev-to-current-branch.sh --skip-submodules
```

## Options
- `--remote <name>`: remote name to fetch/push (default `origin`)
- `--dev-branch <name>`: source branch to merge from (default `dev`)
- `--sync-mode <merge|ff-only>`: merge diverged branches (default) or require strict fast-forward
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
