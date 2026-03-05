---
name: auto-dev
description: >
  Autonomous development and debugging in the current worktree with strict git
  safety. Trigger when user says "go auto-dev" or asks to start auto-dev. Use
  for coding, testing, MCP/skills (e.g., Playwright), cloud inspection
  (Firestore/Storage/GCP), web browsing, or GitHub Actions deploys for the
  current branch. Default policy blocks dev/main and cross-branch pushes, with
  a narrow exception for explicit `skills-hub` maintenance on `main` and draft
  PR handoff. Prompt for required credentials or session values via command
  input.
---

# Auto Dev

This skill is designed for reuse across projects. Keep business-specific behavior in project packs and inject it via `.skills-hub/` hooks.

## Guardrails
- Confirm scope with `pwd`; keep all reads/writes inside the current worktree.
- Read the current branch with `git rev-parse --abbrev-ref HEAD`.
- If the branch is `dev` or `main`, stop and ask the user to switch by default.
- Never checkout, merge, rebase, or push `dev` or `main` by default.
- Never push to any remote branch other than the current branch name by default.
- Never force-push or rewrite remote history.
- `skills-hub` exception (explicit user request only):
  - Allow operating on `main` only in the `skills-hub` repo.
  - Allow commit/push to `origin/main` only after task completion and explicit confirmation.
  - Keep all other protections unchanged.

## Secure context input
- Request needed credentials, test accounts, or session values (e.g., `app_session`, test account/password) via command input.
- Do not persist secrets in files or commit history.

## Scripts (in ~/.codex/skills/auto-dev/scripts)
- `auto-dev-preflight.sh`: verify repo scope and branch safety; emits `AUTO_DEV_REPO_ROOT`, `AUTO_DEV_BRANCH`, and Chrome MCP readiness hints.
- `auto-dev-deploy-dev.sh`: generic workflow trigger runner. It reads project-specific deploy mapping from `AUTO_DEV_INFER_SCRIPT` or `<repo>/.skills-hub/auto-dev/infer-targets.sh`.

## Project-specific logic (keep out of core skill)
- Store business mapping, deployment knobs, and repo shortcuts in a project pack (for example `project-packs/<project>/...`).
- Keep `SKILL.md` and core scripts generic; inject business behavior via the infer script only.

## Browser automation preference
- Default MCP for browser work: **chrome-devtools-mcp** (fast, reliable).
  - If `AUTO_DEV_CHROME_MCP_READY=1`, use Chrome MCP immediately.
  - If not ready, run `chrome-mcp-remote` start script and re-check quickly.
- Fallback MCP: **playwright-mcp** when chrome-devtools is unavailable or for cross-browser checks.
  - Playwright supports Chromium/Firefox/WebKit (Safari-like engine on macOS). If the user needs the actual Safari app, ask for clarification.

## Capabilities
- Use any skills and MCP tools (chrome-devtools-mcp preferred; Playwright as backup) for autonomous development and debugging.
- Allowed actions include inspecting Firestore/Storage data, accessing GCP, browsing web UIs, and triggering GitHub Actions for the current branch.

## Draft PR and publish flow
- Preferred handoff after completion: create a draft PR for review context, e.g., `gh pr create --draft --base main --head <current-branch>`.
- For `skills-hub` only, if the user explicitly requests direct publish to `main`, commit and push to `origin/main`.
- Keep commit messages scoped and clear so draft PR and direct-push history are both auditable.

## GitHub Actions deploy (current branch only)
- Trigger workflows with the current branch ref, e.g., `gh workflow run dev.yml --ref <current-branch>`.
- Confirm the workflow targets the dev environment for the current branch only.

## Reporting
- Summarize changes and commands run.
- Provide quick verification steps when applicable.
