#!/usr/bin/env bash
set -euo pipefail

hub_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
pack_name=""
target_repo="$(pwd -P)"
dry_run=false
list_only=false

usage() {
  cat <<USAGE
Usage: scripts/link-project-pack.sh --pack <name> [--repo <path>] [--dry-run]
       scripts/link-project-pack.sh --list

Options:
  --pack <name>   project pack name under project-packs/
  --repo <path>   target repository path (default: current directory)
  --dry-run       print link actions only
  --list          list available project packs
  -h, --help      show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pack)
      pack_name="$2"
      shift
      ;;
    --repo)
      target_repo="$2"
      shift
      ;;
    --dry-run)
      dry_run=true
      ;;
    --list)
      list_only=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$list_only" == "true" ]]; then
  find "$hub_root/project-packs" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  exit 0
fi

if [[ -z "$pack_name" ]]; then
  echo "--pack is required (or use --list)." >&2
  usage >&2
  exit 1
fi

pack_dir="$hub_root/project-packs/$pack_name"
if [[ ! -d "$pack_dir" ]]; then
  echo "Project pack not found: $pack_name" >&2
  exit 1
fi

if [[ ! -d "$target_repo" ]]; then
  echo "Target repository path does not exist: $target_repo" >&2
  exit 1
fi

skills_hub_dir="$target_repo/.skills-hub"

for entry in "$pack_dir"/*; do
  [[ -d "$entry" ]] || continue
  name="$(basename "$entry")"
  target="$skills_hub_dir/$name"

  if [[ "$dry_run" == "true" ]]; then
    echo "ln -sfn $entry $target"
    continue
  fi

  mkdir -p "$skills_hub_dir"
  ln -sfn "$entry" "$target"
  echo "Linked project pack path: $target -> $entry"
done
