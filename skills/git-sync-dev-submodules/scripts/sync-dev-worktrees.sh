#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib-sync-dev.sh
source "$SCRIPT_DIR/lib-sync-dev.sh"

REMOTE="origin"
DEV_BRANCH="dev"
DRY_RUN=0
HAS_FAILURE=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Fast sync flow for every worktree:
1) Run this script from a '$DEV_BRANCH' worktree.
2) Fetch once from the remote.
3) Fast-forward the current '$DEV_BRANCH' worktree to '$REMOTE/$DEV_BRANCH'.
4) Rebase every other non-detached, clean worktree onto the local '$DEV_BRANCH'.

Options:
  --remote <name>           Remote name (default: origin)
  --dev-branch <name>       Source branch (default: dev)
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

if [[ "$CURRENT_BRANCH" != "$DEV_BRANCH" ]]; then
  sync_dev_die "Current branch is '$CURRENT_BRANCH'. Run this script from a '$DEV_BRANCH' worktree, or use sync-dev-to-current-branch.sh instead."
fi

sync_dev_log "Dev worktree: $CURRENT_WORKTREE"
sync_dev_require_clean "$CURRENT_WORKTREE" "Current dev worktree"
sync_dev_fetch "$CURRENT_WORKTREE" "$REMOTE"
sync_dev_ensure_remote_branch "$CURRENT_WORKTREE" "$REMOTE" "$DEV_BRANCH"

sync_dev_log "Fast-forward '$DEV_BRANCH' to '$REMOTE/$DEV_BRANCH'"
if [[ "$DRY_RUN" -eq 0 ]]; then
  git -C "$CURRENT_WORKTREE" merge --ff-only "$REMOTE/$DEV_BRANCH" >/dev/null
fi

declare -a worktree_paths=()
declare -a worktree_branches=()
declare -a updated=()
declare -a skipped_dirty=()
declare -a skipped_detached=()
declare -a failed=()

block_path=""
block_branch=""
while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    if [[ -n "$block_path" ]]; then
      worktree_paths+=("$block_path")
      worktree_branches+=("$block_branch")
    fi
    block_path=""
    block_branch=""
    continue
  fi

  case "$line" in
    worktree\ *)
      block_path="${line#worktree }"
      ;;
    branch\ refs/heads/*)
      block_branch="${line#branch refs/heads/}"
      ;;
    detached)
      block_branch="__DETACHED__"
      ;;
  esac
done < <(git -C "$CURRENT_WORKTREE" worktree list --porcelain; printf '\n')

for index in "${!worktree_paths[@]}"; do
  worktree_path="${worktree_paths[$index]}"
  worktree_branch="${worktree_branches[$index]}"

  if [[ "$worktree_path" == "$CURRENT_WORKTREE" ]]; then
    updated+=("$worktree_path:$DEV_BRANCH")
    continue
  fi

  if [[ -z "$worktree_branch" || "$worktree_branch" == "__DETACHED__" ]]; then
    skipped_detached+=("$worktree_path")
    continue
  fi

  if ! sync_dev_is_clean "$worktree_path"; then
    skipped_dirty+=("$worktree_path:$worktree_branch")
    continue
  fi

  sync_dev_log "Rebase '$worktree_branch' in '$worktree_path' onto '$DEV_BRANCH'"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    if ! git -C "$worktree_path" rebase "$DEV_BRANCH" >/dev/null; then
      git -C "$worktree_path" rebase --abort >/dev/null 2>&1 || true
      sync_dev_warn "Rebase failed for '$worktree_branch' in '$worktree_path'; aborted and skipped"
      failed+=("$worktree_path:$worktree_branch")
      HAS_FAILURE=1
      continue
    fi
  fi

  updated+=("$worktree_path:$worktree_branch")
done

sync_dev_log "Done"
sync_dev_log "Updated worktrees: ${#updated[@]}"
for item in "${updated[@]}"; do
  sync_dev_log "  updated -> $item"
done

if [[ ${#skipped_detached[@]} -gt 0 ]]; then
  sync_dev_log "Skipped detached worktrees: ${#skipped_detached[@]}"
  for item in "${skipped_detached[@]}"; do
    sync_dev_log "  skipped(detached) -> $item"
  done
fi

if [[ ${#skipped_dirty[@]} -gt 0 ]]; then
  sync_dev_log "Skipped dirty worktrees: ${#skipped_dirty[@]}"
  for item in "${skipped_dirty[@]}"; do
    sync_dev_log "  skipped(dirty) -> $item"
  done
fi

if [[ ${#failed[@]} -gt 0 ]]; then
  sync_dev_warn "Failed worktrees: ${#failed[@]}"
  for item in "${failed[@]}"; do
    sync_dev_warn "  failed -> $item"
  done
fi

if [[ "$HAS_FAILURE" -ne 0 && "$DRY_RUN" -eq 0 ]]; then
  exit 1
fi
