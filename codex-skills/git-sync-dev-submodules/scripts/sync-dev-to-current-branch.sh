#!/usr/bin/env bash
set -euo pipefail

REMOTE="origin"
DEV_BRANCH="dev"
SUBMODULES="func-core"
SKIP_SUBMODULES=0
SYNC_MODE="merge"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Sync origin/dev into the current branch, then push current branch.
Optionally sync submodule branches from origin/dev and push them too.

Options:
  --remote <name>           Remote name (default: origin)
  --dev-branch <name>       Source branch to merge from (default: dev)
  --sync-mode <mode>        Sync mode: merge|ff-only (default: merge)
  --submodules <list|all>   Comma-separated submodule paths, or 'all' (default: func-core)
  --skip-submodules         Skip submodule sync
  --help                    Show this help
USAGE
}

log() {
  printf '[sync-dev] %s\n' "$*"
}

warn() {
  printf '[sync-dev][warn] %s\n' "$*" >&2
}

die() {
  printf '[sync-dev][error] %s\n' "$*" >&2
  exit 1
}

ensure_mode() {
  case "$1" in
    merge|ff-only) ;;
    *) die "Invalid --sync-mode '$1'. Use: merge or ff-only" ;;
  esac
}

require_clean_repo() {
  local repo_path="$1"
  local label="$2"
  if [[ -n "$(git -C "$repo_path" status --porcelain)" ]]; then
    die "$label has uncommitted changes. Commit or stash first."
  fi
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
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
    git -C "$repo_path" checkout "$branch"
    return 0
  fi

  if git -C "$repo_path" show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    git -C "$repo_path" checkout -b "$branch" --track "$remote/$branch"
    return 0
  fi

  return 1
}

array_contains() {
  local needle="$1"
  shift
  local item=""
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

read_dev_counts() {
  local repo_path="$1"
  local raw=""
  raw="$(git -C "$repo_path" rev-list --left-right --count "$REMOTE/$DEV_BRANCH"...HEAD)"
  printf '%s %s\n' "$(awk '{print $1}' <<<"$raw")" "$(awk '{print $2}' <<<"$raw")"
}

assert_contains_dev() {
  local repo_path="$1"
  local label="$2"
  local behind ahead
  read -r behind ahead < <(read_dev_counts "$repo_path")
  if [[ "$behind" != "0" ]]; then
    die "$label does not contain '$REMOTE/$DEV_BRANCH' after sync (behind=$behind ahead=$ahead)."
  fi
}

merge_superproject_with_dev() {
  local super_branch="$1"
  local behind ahead
  read -r behind ahead < <(read_dev_counts "$REPO_ROOT")

  if [[ "$behind" == "0" ]]; then
    log "Superproject already contains '$REMOTE/$DEV_BRANCH' (ahead=$ahead)"
    return 0
  fi

  if [[ "$ahead" == "0" ]]; then
    log "Fast-forward superproject branch '$super_branch' with '$REMOTE/$DEV_BRANCH'"
    git merge --ff-only "$REMOTE/$DEV_BRANCH"
    assert_contains_dev "$REPO_ROOT" "Superproject branch '$super_branch'"
    return 0
  fi

  if [[ "$SYNC_MODE" == "ff-only" ]]; then
    die "Superproject branch '$super_branch' diverged from '$REMOTE/$DEV_BRANCH' (behind=$behind ahead=$ahead). Re-run with --sync-mode merge."
  fi

  log "Merge superproject branch '$super_branch' with '$REMOTE/$DEV_BRANCH' (diverged: behind=$behind ahead=$ahead)"
  set +e
  git merge --no-ff --no-commit "$REMOTE/$DEV_BRANCH"
  local merge_rc=$?
  set -e

  if [[ "$merge_rc" -eq 0 ]]; then
    git commit -m "merge: sync $REMOTE/$DEV_BRANCH into $super_branch"
    assert_contains_dev "$REPO_ROOT" "Superproject branch '$super_branch'"
    return 0
  fi

  local unresolved_paths=()
  local unresolved_item=""
  while IFS= read -r unresolved_item; do
    if [[ -n "$unresolved_item" ]]; then
      unresolved_paths+=("$unresolved_item")
    fi
  done < <(git diff --name-only --diff-filter=U)
  if [[ ${#unresolved_paths[@]} -eq 0 ]]; then
    git merge --abort || true
    die "Superproject merge failed for unknown reason."
  fi

  local p=""
  local mode=""
  for p in "${unresolved_paths[@]}"; do
    mode="$(git ls-files -u -- "$p" | awk 'NR==1 {print $1}')"
    if [[ "$mode" != "160000" ]]; then
      git merge --abort || true
      die "Superproject merge conflict is not a submodule pointer: '$p'. Resolve manually."
    fi

    if [[ "$SKIP_SUBMODULES" -eq 0 ]] && array_contains "$p" "${submodule_paths[@]}"; then
      log "Auto-resolve submodule conflict '$p' with ours (selected for re-sync)"
      git checkout --ours -- "$p"
    else
      log "Auto-resolve submodule conflict '$p' with theirs"
      git checkout --theirs -- "$p"
    fi
    git add "$p"
  done

  if [[ -n "$(git diff --name-only --diff-filter=U)" ]]; then
    git merge --abort || true
    die "Unresolved conflicts remain after submodule conflict auto-resolution."
  fi

  git commit -m "merge: sync $REMOTE/$DEV_BRANCH into $super_branch"
  assert_contains_dev "$REPO_ROOT" "Superproject branch '$super_branch'"
}

sync_one_submodule() {
  local sub_path="$1"
  local super_branch="$2"

  [[ -e "$sub_path" ]] || die "Submodule path '$sub_path' does not exist."

  git submodule update --init --recursive "$sub_path"

  require_clean_repo "$sub_path" "Submodule '$sub_path'"

  git -C "$sub_path" fetch "$REMOTE" --prune

  git -C "$sub_path" show-ref --verify --quiet "refs/remotes/$REMOTE/$DEV_BRANCH" \
    || die "Submodule '$sub_path' has no '$REMOTE/$DEV_BRANCH'."

  local sub_branch="$super_branch"

  if ! checkout_branch_if_needed "$sub_path" "$sub_branch" "$REMOTE"; then
    log "Create submodule branch '$sub_branch' in '$sub_path'"
    git -C "$sub_path" checkout -b "$sub_branch"
  fi

  local behind ahead
  read -r behind ahead < <(read_dev_counts "$sub_path")

  if [[ "$behind" == "0" ]]; then
    log "Submodule '$sub_path' branch '$sub_branch' already contains '$REMOTE/$DEV_BRANCH' (ahead=$ahead)"
  elif [[ "$ahead" == "0" ]]; then
    log "Fast-forward submodule '$sub_path' branch '$sub_branch' with '$REMOTE/$DEV_BRANCH'"
    git -C "$sub_path" merge --ff-only "$REMOTE/$DEV_BRANCH"
  else
    if [[ "$SYNC_MODE" == "ff-only" ]]; then
      die "Submodule '$sub_path' branch '$sub_branch' diverged from '$REMOTE/$DEV_BRANCH' (behind=$behind ahead=$ahead). Re-run with --sync-mode merge."
    fi
    log "Merge submodule '$sub_path' branch '$sub_branch' with '$REMOTE/$DEV_BRANCH' (diverged: behind=$behind ahead=$ahead)"
    git -C "$sub_path" merge --no-ff "$REMOTE/$DEV_BRANCH" -m "merge($sub_path): sync $REMOTE/$DEV_BRANCH into $sub_branch"
  fi

  assert_contains_dev "$sub_path" "Submodule '$sub_path' branch '$sub_branch'"

  log "Push submodule '$sub_path' branch '$sub_branch'"
  git -C "$sub_path" push "$REMOTE" "$sub_branch"

  synced_submodules+=("$sub_path:$sub_branch")
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
    --sync-mode)
      [[ $# -lt 2 ]] && die "Missing value for --sync-mode"
      SYNC_MODE="$2"
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
ensure_mode "$SYNC_MODE"

SUPER_BRANCH="$(git symbolic-ref --quiet --short HEAD || true)"
[[ -z "$SUPER_BRANCH" ]] && die "Superproject is in detached HEAD state"

log "Repository: $REPO_ROOT"
log "Current branch: $SUPER_BRANCH"
log "Sync mode: $SYNC_MODE"

require_clean_repo "$REPO_ROOT" "Superproject"

git fetch "$REMOTE" --prune

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
      git submodule update --init --recursive "$local_item"
      require_clean_repo "$local_item" "Submodule '$local_item'"
    done
  fi
else
  log "Skip submodule sync by flag"
fi

merge_superproject_with_dev "$SUPER_BRANCH"

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
  commit_msg="chore: sync submodule(s) ${changed_submodule_paths[*]} to $DEV_BRANCH"
  log "Commit superproject submodule pointer update"
  git commit -m "$commit_msg"
fi

log "Push superproject branch '$SUPER_BRANCH'"
git push "$REMOTE" "$SUPER_BRANCH"

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
