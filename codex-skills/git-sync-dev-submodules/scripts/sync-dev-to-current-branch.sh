#!/usr/bin/env bash
set -euo pipefail

REMOTE="origin"
DEV_BRANCH="dev"
SUBMODULES="func-core"
SKIP_SUBMODULES=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Simplified sync flow:
1) Verify current branch content is already merged into origin/dev.
2) If yes, rebase current branch onto origin/dev.
3) Push current branch.
4) Apply the same check/rebase/push flow to selected submodules.

Options:
  --remote <name>           Remote name (default: origin)
  --dev-branch <name>       Source branch (default: dev)
  --submodules <list|all>   Comma-separated submodule paths, or 'all' (default: func-core)
  --skip-submodules         Skip submodule sync
  --help                    Show this help
USAGE
}

log() {
  printf '[sync-dev] %s\n' "$*"
}

die() {
  printf '[sync-dev][error] %s\n' "$*" >&2
  exit 1
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

require_clean_repo() {
  local repo_path="$1"
  local label="$2"
  if [[ -n "$(git -C "$repo_path" status --porcelain)" ]]; then
    die "$label has uncommitted changes. Commit or stash first."
  fi
}

resolve_submodule_paths() {
  local mode="$1"
  if [[ "$mode" == "all" ]]; then
    if [[ ! -f .gitmodules ]]; then
      return 0
    fi
    git config --file .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}'
    return 0
  fi

  local IFS=','
  read -r -a raw_paths <<< "$mode"
  local p
  for p in "${raw_paths[@]}"; do
    p="$(trim "$p")"
    if [[ -n "$p" ]]; then
      printf '%s\n' "$p"
    fi
  done
}

collect_submodule_paths() {
  local mode="$1"
  local item=""
  while IFS= read -r item; do
    if [[ -n "$item" ]]; then
      submodule_paths+=("$item")
    fi
  done < <(resolve_submodule_paths "$mode")
}

checkout_branch_if_needed() {
  local repo_path="$1"
  local branch="$2"
  local remote="$3"

  if git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$repo_path" checkout "$branch" >/dev/null
    return 0
  fi

  if git -C "$repo_path" show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    git -C "$repo_path" checkout -b "$branch" --track "$remote/$branch" >/dev/null
    return 0
  fi

  # Create new branch from origin/dev when no same-name branch exists yet.
  git -C "$repo_path" checkout -b "$branch" "$remote/$DEV_BRANCH" >/dev/null
}

read_dev_counts() {
  local repo_path="$1"
  local raw=""
  raw="$(git -C "$repo_path" rev-list --left-right --count "$REMOTE/$DEV_BRANCH"...HEAD)"
  printf '%s %s\n' "$(awk '{print $1}' <<<"$raw")" "$(awk '{print $2}' <<<"$raw")"
}

ensure_merged_into_dev() {
  local repo_path="$1"
  local label="$2"
  if ! git -C "$repo_path" merge-base --is-ancestor HEAD "$REMOTE/$DEV_BRANCH"; then
    local behind ahead
    read -r behind ahead < <(read_dev_counts "$repo_path")
    die "$label contains commits not merged into '$REMOTE/$DEV_BRANCH' (behind=$behind ahead=$ahead). Merge it to dev first, then re-run."
  fi
}

rebase_to_dev() {
  local repo_path="$1"
  local label="$2"
  log "Rebase $label onto '$REMOTE/$DEV_BRANCH'"
  git -C "$repo_path" rebase "$REMOTE/$DEV_BRANCH" >/dev/null
}

sync_one_submodule() {
  local sub_path="$1"
  local super_branch="$2"

  [[ -e "$sub_path" ]] || die "Submodule path '$sub_path' does not exist."

  git submodule update --init --recursive "$sub_path" >/dev/null
  require_clean_repo "$sub_path" "Submodule '$sub_path'"

  git -C "$sub_path" fetch "$REMOTE" --prune >/dev/null
  git -C "$sub_path" show-ref --verify --quiet "refs/remotes/$REMOTE/$DEV_BRANCH" \
    || die "Submodule '$sub_path' missing '$REMOTE/$DEV_BRANCH'."

  checkout_branch_if_needed "$sub_path" "$super_branch" "$REMOTE"
  ensure_merged_into_dev "$sub_path" "Submodule '$sub_path' branch '$super_branch'"
  rebase_to_dev "$sub_path" "submodule '$sub_path' branch '$super_branch'"

  log "Push submodule '$sub_path' branch '$super_branch'"
  git -C "$sub_path" push "$REMOTE" "$super_branch" >/dev/null

  synced_submodules+=("$sub_path:$super_branch")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ $# -lt 2 ]] && die "Missing value for --remote"
      REMOTE="$2"
      shift 2
      ;;
    --dev-branch)
      [[ $# -lt 2 ]] && die "Missing value for --dev-branch"
      DEV_BRANCH="$2"
      shift 2
      ;;
    --submodules)
      [[ $# -lt 2 ]] && die "Missing value for --submodules"
      SUBMODULES="$2"
      shift 2
      ;;
    --skip-submodules)
      SKIP_SUBMODULES=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -z "$REPO_ROOT" ]] && die "Not inside a git repository"
cd "$REPO_ROOT"

SUPER_BRANCH="$(git symbolic-ref --quiet --short HEAD || true)"
[[ -z "$SUPER_BRANCH" ]] && die "Superproject is in detached HEAD state"

log "Repository: $REPO_ROOT"
log "Current branch: $SUPER_BRANCH"

require_clean_repo "$REPO_ROOT" "Superproject"

git fetch "$REMOTE" --prune >/dev/null
if ! git show-ref --verify --quiet "refs/remotes/$REMOTE/$DEV_BRANCH"; then
  die "Missing '$REMOTE/$DEV_BRANCH' in superproject"
fi

declare -a synced_submodules=()
declare -a submodule_paths=()

if [[ "$SKIP_SUBMODULES" -eq 0 ]]; then
  collect_submodule_paths "$SUBMODULES"

  if [[ ${#submodule_paths[@]} -eq 0 ]]; then
    log "No submodules selected"
  else
    local_item=""
    for local_item in "${submodule_paths[@]}"; do
      [[ -e "$local_item" ]] || die "Selected submodule '$local_item' does not exist."
      git submodule update --init --recursive "$local_item" >/dev/null
      require_clean_repo "$local_item" "Submodule '$local_item'"
    done
  fi
else
  log "Skip submodule sync by flag"
fi

ensure_merged_into_dev "$REPO_ROOT" "Superproject branch '$SUPER_BRANCH'"
rebase_to_dev "$REPO_ROOT" "superproject branch '$SUPER_BRANCH'"

if [[ "$SKIP_SUBMODULES" -eq 0 ]] && [[ ${#submodule_paths[@]} -gt 0 ]]; then
  local_item=""
  for local_item in "${submodule_paths[@]}"; do
    sync_one_submodule "$local_item" "$SUPER_BRANCH"
  done
fi

declare -a changed_submodule_paths=()
if [[ "$SKIP_SUBMODULES" -eq 0 ]]; then
  for local_item in "${submodule_paths[@]:-}"; do
    if [[ -n "$local_item" ]] && git ls-files --stage -- "$local_item" >/dev/null 2>&1; then
      if ! git diff --quiet -- "$local_item"; then
        changed_submodule_paths+=("$local_item")
      fi
    fi
  done
fi

if [[ ${#changed_submodule_paths[@]} -gt 0 ]]; then
  git add "${changed_submodule_paths[@]}"
  commit_msg="chore: sync submodule(s) ${changed_submodule_paths[*]} to $DEV_BRANCH via rebase"
  log "Commit superproject submodule pointer update"
  git commit -m "$commit_msg" >/dev/null
fi

log "Push superproject branch '$SUPER_BRANCH'"
git push "$REMOTE" "$SUPER_BRANCH" >/dev/null

log "Done"
log "Superproject HEAD: $(git rev-parse --short HEAD)"
log "Superproject dev alignment: $(git rev-list --left-right --count "$REMOTE/$DEV_BRANCH"...HEAD)"

if [[ ${#synced_submodules[@]} -gt 0 ]]; then
  for local_item in "${synced_submodules[@]}"; do
    sub_path="${local_item%%:*}"
    sub_branch="${local_item##*:}"
    log "Submodule '$sub_path' branch '$sub_branch' HEAD: $(git -C "$sub_path" rev-parse --short HEAD)"
    log "Submodule '$sub_path' dev alignment: $(git -C "$sub_path" rev-list --left-right --count "$REMOTE/$DEV_BRANCH"...HEAD)"
  done
fi
