#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repository." >&2
  exit 1
fi

cd "$repo_root"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" == "HEAD" ]]; then
  echo "Detached HEAD is not allowed for auto-dev." >&2
  exit 1
fi

repo_name="$(basename "$repo_root")"
allow_skills_hub_main="${AUTO_DEV_ALLOW_SKILLS_HUB_MAIN:-}"
skills_hub_main_token="skills-hub-main-confirmed"
if [[ "$current_branch" == "dev" || "$current_branch" == "main" ]]; then
  if [[ "$current_branch" == "main" && "$repo_name" == "skills-hub" && "$allow_skills_hub_main" == "$skills_hub_main_token" ]]; then
    echo "Warning: allowing skills-hub main by explicit override (AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=$skills_hub_main_token)." >&2
  else
    if [[ "$current_branch" == "main" && "$repo_name" == "skills-hub" ]]; then
      echo "Refusing to operate on skills-hub main without the explicit confirmation token." >&2
      echo "Set AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=$skills_hub_main_token only for the protected command you intend to run." >&2
    fi
    echo "Refusing to operate on protected branch: $current_branch" >&2
    exit 1
  fi
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Warning: working tree is dirty; deploy uses remote branch only." >&2
fi

printf 'AUTO_DEV_REPO_ROOT=%q\n' "$repo_root"
printf 'AUTO_DEV_BRANCH=%q\n' "$current_branch"
