#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

link_codex=true
link_claude=true

usage() {
  cat <<USAGE
Usage: scripts/link-local.sh [--codex-only] [--claude-only]

Options:
  --codex-only   only link codex-skills to ~/.codex/skills
  --claude-only  only link claude-skills / claude-commands to ~/.claude
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-only)
      link_codex=true
      link_claude=false
      ;;
    --claude-only)
      link_codex=false
      link_claude=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$link_codex" == "true" ]]; then
  mkdir -p "$HOME/.codex/skills"

  for skill_dir in "$repo_root"/codex-skills/*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    ln -sfn "$skill_dir" "$HOME/.codex/skills/$skill_name"
    echo "Linked Codex skill: $skill_name"
  done
fi

if [[ "$link_claude" == "true" ]]; then
  mkdir -p "$HOME/.claude/skills"
  mkdir -p "$HOME/.claude/commands"

  for skill_file in "$repo_root"/claude-skills/*.md; do
    [[ -f "$skill_file" ]] || continue
    target="$HOME/.claude/skills/$(basename "$skill_file")"
    ln -sfn "$skill_file" "$target"
    echo "Linked Claude skill: $(basename "$skill_file")"
  done

  while IFS= read -r -d "" file; do
    rel_path="${file#"$repo_root/claude-commands/"}"
    target="$HOME/.claude/commands/$rel_path"
    mkdir -p "$(dirname "$target")"
    ln -sfn "$file" "$target"
    echo "Linked Claude command: $rel_path"
  done < <(find "$repo_root/claude-commands" -type f -name "*.md" -print0)
fi

