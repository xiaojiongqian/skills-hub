#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib-sync-dev.sh
source "$SCRIPT_DIR/lib-sync-dev.sh"

REMOTE="origin"
DEV_BRANCH="dev"
SUBMODULES="func-core"
SKIP_SUBMODULES=0
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Fast sync flow for the current worktree:
1) Fetch once from the remote.
2) If current branch is '$DEV_BRANCH', fast-forward it to '$REMOTE/$DEV_BRANCH'.
3) Otherwise, rebase the current branch onto '$REMOTE/$DEV_BRANCH'.
4) Refresh selected submodules by default.

Options:
  --remote <name>           Remote name (default: origin)
  --dev-branch <name>       Source branch (default: dev)
  --submodules <list|all>   Comma-separated submodule paths, or 'all' (default: func-core)
  --skip-submodules         Skip submodule refresh
  --dry-run                 Print planned actions without changing git state
  --help                    Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ $# -lt 2 ]] && sync_dev_die "Missing value for --remote"
      REMOTE="$2"
      shift 2
      ;;
    --dev-branch)
      [[ $# -lt 2 ]] && sync_dev_die "Missing value for --dev-branch"
      DEV_BRANCH="$2"
      shift 2
      ;;
    --submodules)
      [[ $# -lt 2 ]] && sync_dev_die "Missing value for --submodules"
      SUBMODULES="$2"
      shift 2
      ;;
    --skip-submodules)
      SKIP_SUBMODULES=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      sync_dev_die "Unknown option: $1"
      ;;
  esac
done

CURRENT_WORKTREE="$(sync_dev_repo_root ".")"
[[ -n "$CURRENT_WORKTREE" ]] || sync_dev_die "Not inside a git repository"

CURRENT_BRANCH="$(sync_dev_branch "$CURRENT_WORKTREE")"
[[ -n "$CURRENT_BRANCH" ]] || sync_dev_die "Current worktree is in detached HEAD state"

sync_dev_log "Worktree: $CURRENT_WORKTREE"
sync_dev_log "Branch: $CURRENT_BRANCH"

sync_dev_require_clean "$CURRENT_WORKTREE" "Current worktree"
sync_dev_fetch "$CURRENT_WORKTREE" "$REMOTE"
sync_dev_ensure_remote_branch "$CURRENT_WORKTREE" "$REMOTE" "$DEV_BRANCH"

if [[ "$CURRENT_BRANCH" == "$DEV_BRANCH" ]]; then
  sync_dev_log "Fast-forward '$DEV_BRANCH' to '$REMOTE/$DEV_BRANCH'"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    git -C "$CURRENT_WORKTREE" merge --ff-only "$REMOTE/$DEV_BRANCH" >/dev/null
  fi
else
  sync_dev_log "Rebase '$CURRENT_BRANCH' onto '$REMOTE/$DEV_BRANCH'"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    git -C "$CURRENT_WORKTREE" rebase "$REMOTE/$DEV_BRANCH" >/dev/null
  fi
fi

if [[ "$SKIP_SUBMODULES" -eq 0 ]]; then
  sync_dev_update_submodules "$CURRENT_WORKTREE" "$SUBMODULES" "$DRY_RUN"
else
  sync_dev_log "Skip submodule refresh by flag"
fi

sync_dev_log "Done"
sync_dev_log "Alignment vs '$REMOTE/$DEV_BRANCH': $(sync_dev_alignment_counts "$CURRENT_WORKTREE" "$REMOTE/$DEV_BRANCH" HEAD)"
