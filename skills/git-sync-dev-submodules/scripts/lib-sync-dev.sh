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
