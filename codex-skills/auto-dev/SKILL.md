---
name: auto-dev
description: >
  Autonomous development and debugging in the current worktree with strict git
  safety. Trigger when user says "go auto-dev" or asks to start auto-dev. Use
  for coding, testing, MCP/skills (e.g., Playwright), cloud inspection
  (Firestore/Storage/GCP), web browsing, or GitHub Actions deploys for the
  current branch. Always stay in the current worktree, allow commit/push only
  on the current branch, and never target dev/main or any other remote branch.
  Prompt for required credentials or session values via command input.
---

# Auto Dev

## Guardrails
- Confirm scope with `pwd`; keep all reads/writes inside the current worktree.
- Read the current branch with `git rev-parse --abbrev-ref HEAD`.
- If the branch is `dev` or `main`, stop and ask the user to switch.
- Never checkout, merge, rebase, or push `dev` or `main`.
- Never push to any remote branch other than the current branch name.
- Never force-push or rewrite remote history.

## Secure context input
- Request needed credentials, test accounts, or session values (e.g., `app_session`, test account/password) via command input.
- Do not persist secrets in files or commit history.

## Scripts (in ~/.codex/skills/auto-dev/scripts)
- `auto-dev-preflight.sh`: verify repo scope and branch safety; emits `AUTO_DEV_REPO_ROOT`, `AUTO_DEV_BRANCH`, and Chrome MCP readiness hints.
- `auto-dev-deploy-dev.sh`: auto-detect deploy inputs based on changes and trigger the dev workflow for the current branch.

## Browser automation preference
- Default MCP for browser work: **chrome-devtools-mcp** (fast, reliable).
  - If `AUTO_DEV_CHROME_MCP_READY=1`, use Chrome MCP immediately.
  - If not ready, run `chrome-mcp-remote` start script and re-check quickly.
- Fallback MCP: **playwright-mcp** when chrome-devtools is unavailable or for cross-browser checks.
  - Playwright supports Chromium/Firefox/WebKit (Safari-like engine on macOS). If the user needs the actual Safari app, ask for clarification.

## Capabilities
- Use any skills and MCP tools (chrome-devtools-mcp preferred; Playwright as backup) for autonomous development and debugging.
- Allowed actions include inspecting Firestore/Storage data, accessing GCP, browsing web UIs, and triggering GitHub Actions for the current branch.

## GitHub Actions deploy (current branch only)
- Trigger workflows with the current branch ref, e.g., `gh workflow run dev.yml --ref <current-branch>`.
- Confirm the workflow targets the dev environment for the current branch only.

## Reporting
- Summarize changes and commands run.
- Provide quick verification steps when applicable.
