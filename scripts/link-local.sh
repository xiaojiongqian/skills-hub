#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

link_codex=true
link_claude=true
install_claude_mcp=false

usage() {
  cat <<USAGE
Usage: scripts/link-local.sh [--codex-only] [--claude-only] [--install-claude-mcp]

Options:
  --codex-only   only link skills/ to ~/.codex/skills
  --claude-only  only link skills/ and helper scripts to ~/.claude
  --install-claude-mcp  run scripts/install-claude-mcp.sh after Claude linking
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
    --install-claude-mcp)
      install_claude_mcp=true
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

  for skill_dir in "$repo_root"/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    ln -sfn "$skill_dir" "$HOME/.codex/skills/$skill_name"
    echo "Linked Codex skill: $skill_name"
  done
fi

if [[ "$link_claude" == "true" ]]; then
  mkdir -p "$HOME/.claude/skills"
  mkdir -p "$HOME/.claude/scripts"

  for skill_dir in "$repo_root"/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
    echo "Linked Claude skill: $skill_name"
  done

  for helper_script in "$repo_root"/scripts/*.sh; do
    [[ -f "$helper_script" ]] || continue
    target="$HOME/.claude/scripts/$(basename "$helper_script")"
    ln -sfn "$helper_script" "$target"
    echo "Linked Claude helper script: $(basename "$helper_script")"
  done

  if [[ "$install_claude_mcp" == "true" ]]; then
    echo "Installing Claude MCP servers (playwright-mcp + chrome-devtools)..."
    bash "$repo_root/scripts/install-claude-mcp.sh" --scope user
  fi
fi
