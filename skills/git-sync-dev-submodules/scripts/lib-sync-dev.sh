#!/usr/bin/env bash

sync_dev_log() {
  printf '[sync-dev] %s\n' "$*"
}

sync_dev_warn() {
  printf '[sync-dev][warn] %s\n' "$*" >&2
}

sync_dev_die() {
  printf '[sync-dev][error] %s\n' "$*" >&2
  exit 1
}

sync_dev_trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

sync_dev_repo_root() {
  git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null || true
}

sync_dev_branch() {
  git -C "$1" symbolic-ref --quiet --short HEAD || true
}

sync_dev_is_clean() {
  [[ -z "$(git -C "$1" status --porcelain)" ]]
}

sync_dev_require_clean() {
  local repo_path="$1"
  local label="$2"

  if ! sync_dev_is_clean "$repo_path"; then
    sync_dev_die "$label has uncommitted changes. Commit or stash first."
  fi
}

sync_dev_fetch() {
  git -C "$1" fetch "$2" --prune >/dev/null
}

sync_dev_ensure_remote_branch() {
  local repo_path="$1"
  local remote="$2"
  local branch="$3"

  if ! git -C "$repo_path" show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    sync_dev_die "Missing '$remote/$branch' in '$repo_path'"
  fi
}

sync_dev_alignment_counts() {
  git -C "$1" rev-list --left-right --count "$2...$3"
}

sync_dev_submodule_recorded_sha() {
  local repo_path="$1"
  local submodule_path="$2"

  git -C "$repo_path" ls-tree HEAD "$submodule_path" | awk '{print $3}'
}

sync_dev_submodule_actual_sha() {
  local repo_path="$1"
  local submodule_path="$2"

  git -C "$repo_path/$submodule_path" rev-parse HEAD 2>/dev/null || true
}

sync_dev_attach_submodule_branch() {
  local repo_path="$1"
  local submodule_path="$2"
  local target_branch="$3"
  local target_sha="$4"
  local submodule_repo="$repo_path/$submodule_path"
  local current_branch=""

  if [[ -z "$target_branch" ]]; then
    sync_dev_log "Keep submodule '$submodule_path' detached in '$repo_path' (superproject detached)"
    return 0
  fi

  if ! sync_dev_is_clean "$submodule_repo"; then
    sync_dev_warn "Submodule '$submodule_path' in '$repo_path' has local changes; cannot align branch '$target_branch'"
    return 1
  fi

  current_branch="$(git -C "$submodule_repo" symbolic-ref --quiet --short HEAD || true)"
  if [[ "$current_branch" == "$target_branch" ]]; then
    git -C "$submodule_repo" reset --hard "$target_sha" >/dev/null
  else
    git -C "$submodule_repo" checkout -B "$target_branch" "$target_sha" >/dev/null
  fi

  if git -C "$submodule_repo" show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    git -C "$submodule_repo" branch --set-upstream-to "origin/$target_branch" "$target_branch" >/dev/null 2>&1 || true
  fi

  sync_dev_log "Aligned submodule '$submodule_path' in '$repo_path' to branch '$target_branch' @ '$target_sha'"
}

sync_dev_resolve_submodule_paths() {
  local repo_path="$1"
  local mode="$2"

  if [[ "$mode" == "all" ]]; then
    if [[ ! -f "$repo_path/.gitmodules" ]]; then
      return 0
    fi

    (
      cd "$repo_path"
      git config --file .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}'
    )
    return 0
  fi

  local IFS=','
  local raw_paths=()
  local item=""
  read -r -a raw_paths <<< "$mode"
  for item in "${raw_paths[@]}"; do
    item="$(sync_dev_trim "$item")"
    if [[ -n "$item" ]]; then
      printf '%s\n' "$item"
    fi
  done
}

sync_dev_update_submodules() {
  local repo_path="$1"
  local mode="$2"
  local dry_run="$3"

  local item=""
  local repo_branch=""
  local -a requested_paths=()
  local -a existing_paths=()

  while IFS= read -r item; do
    if [[ -n "$item" ]]; then
      requested_paths+=("$item")
    fi
  done < <(sync_dev_resolve_submodule_paths "$repo_path" "$mode")

  if [[ ${#requested_paths[@]} -eq 0 ]]; then
    sync_dev_log "No submodules selected in '$repo_path'"
    return 0
  fi

  for item in "${requested_paths[@]}"; do
    if [[ -e "$repo_path/$item" ]]; then
      existing_paths+=("$item")
    else
      sync_dev_warn "Submodule path '$item' does not exist in '$repo_path'; skip"
    fi
  done

  if [[ ${#existing_paths[@]} -eq 0 ]]; then
    sync_dev_log "No existing submodules to update in '$repo_path'"
    return 0
  fi

  repo_branch="$(sync_dev_branch "$repo_path")"

  if [[ "$dry_run" -eq 1 ]]; then
    sync_dev_log "[dry-run] Would update submodules in '$repo_path': ${existing_paths[*]}"
    if [[ -n "$repo_branch" ]]; then
      sync_dev_log "[dry-run] Would align submodule branches in '$repo_path' to '$repo_branch'"
    fi
    return 0
  fi

  (
    cd "$repo_path"
    git submodule sync --recursive >/dev/null || true
    git submodule update --init --recursive -- "${existing_paths[@]}" >/dev/null
  )

  for item in "${existing_paths[@]}"; do
    local recorded_sha=""
    local actual_sha=""

    recorded_sha="$(sync_dev_submodule_recorded_sha "$repo_path" "$item")"
    actual_sha="$(sync_dev_submodule_actual_sha "$repo_path" "$item")"

    if [[ -z "$recorded_sha" ]]; then
      continue
    fi

    if [[ "$recorded_sha" != "$actual_sha" ]]; then
      sync_dev_warn "Submodule '$item' in '$repo_path' remained at '$actual_sha'; retry with forced checkout to '$recorded_sha'"
      (
        cd "$repo_path"
        git submodule update --init --recursive --checkout --force -- "$item" >/dev/null
      )

      actual_sha="$(sync_dev_submodule_actual_sha "$repo_path" "$item")"
      if [[ "$recorded_sha" != "$actual_sha" ]]; then
        sync_dev_warn "Submodule '$item' in '$repo_path' is still at '$actual_sha' after forced checkout; expected '$recorded_sha'"
        return 1
      fi
    fi

    if ! sync_dev_attach_submodule_branch "$repo_path" "$item" "$repo_branch" "$recorded_sha"; then
      return 1
    fi

    actual_sha="$(sync_dev_submodule_actual_sha "$repo_path" "$item")"
    if [[ "$recorded_sha" != "$actual_sha" ]]; then
      sync_dev_warn "Submodule '$item' in '$repo_path' moved to '$actual_sha' after branch alignment; expected '$recorded_sha'"
      return 1
    fi
  done
}
