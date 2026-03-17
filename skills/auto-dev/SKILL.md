---
name: auto-dev
license: MIT
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
- For GitHub Actions deploys, require the branch to track `origin/<current-branch>`; infer deploy targets from the remote branch state, not unpushed local commits.
- `skills-hub` exception (explicit user request only):
  - Allow operating on `main` only in the `skills-hub` repo.
  - Treat explicit confirmation as part of the protected command invocation, using `AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=skills-hub-main-confirmed`.
  - Allow commit/push to `origin/main` only after task completion and explicit confirmation.
  - Keep all other protections unchanged.

## Secure context input
- Request needed credentials, test accounts, or session values (e.g., `app_session`, test account/password) via command input.
- Do not persist secrets in files or commit history.

## Bundled scripts
- Resolve the installed skill directory as `<path-to-skill>`, then run scripts from `<path-to-skill>/scripts/`.
- `auto-dev-preflight.sh`: verify repo scope and branch safety; emits `AUTO_DEV_REPO_ROOT` and `AUTO_DEV_BRANCH`.
- `auto-dev-deploy-dev.sh`: generic workflow trigger runner. It reads project-specific deploy mapping from `AUTO_DEV_INFER_SCRIPT` or `<repo>/.skills-hub/auto-dev/infer-targets.sh`.
  - The infer script reads changed files on `stdin`.
  - It may emit `workflow=<workflow-file>` and `input:<key>=<value>` lines.
  - The deploy script provides `AUTO_DEV_DEPLOY_REF`, `AUTO_DEV_DEPLOY_SHA`, `AUTO_DEV_DIFF_BASE`, and `AUTO_DEV_DIFF_MERGE_BASE` to the infer script.

## Project-specific logic (keep out of core skill)
- Store business mapping, deployment knobs, and repo shortcuts in a project pack (for example `project-packs/<project>/...`).
- Keep `SKILL.md` and core scripts generic; inject business behavior via the infer script only.

## Browser automation preference
- Default browser route: **`playwright` skill** for one-shot or reproducible browser flows from the terminal.
  - Use it for scripted repro, snapshots, screenshots, traces, data extraction, and quick web UI checks where restarting or re-opening the browser is acceptable.
- Escalate to **`playwright-interactive`** when the task is iterative or stateful.
  - Use it for repeated reloads during local development, persistent browser handles, Electron apps, richer functional plus visual QA, or when the same page/session must survive multiple edits.
- Do not choose Chrome MCP as the default path or backup path.
  - Only use a Chrome MCP workflow when the user explicitly asks for it, or when an existing project workflow already depends on it and it is confirmed working.
  - For browser coverage beyond Chromium, prefer Playwright rather than adding a second MCP-specific branch. If the user needs the actual Safari app, ask for clarification.

## Capabilities
- Use coding, testing, cloud, web, and browser automation skills for autonomous development and debugging, with Playwright CLI first and Playwright Interactive for persistent sessions.
- Allowed actions include inspecting Firestore/Storage data, accessing GCP, browsing web UIs, and triggering GitHub Actions for the current branch.

## Draft PR and publish flow
- Preferred handoff after completion: create a draft PR for review context, e.g., `gh pr create --draft --base main --head <current-branch>`.
- For `skills-hub` only, if the user explicitly requests direct publish to `main`, commit and push to `origin/main`.
- Keep commit messages scoped and clear so draft PR and direct-push history are both auditable.

## GitHub Actions deploy (current branch only)
- Trigger workflows with the current branch ref, e.g., `gh workflow run dev.yml --ref <current-branch>`.
- Use the remote branch state as the source of truth for deploy inference; warn when local `HEAD` differs from `origin/<current-branch>`.
- Default diff base is `origin/main` when available, otherwise resolve `origin/HEAD`; require `--diff-base` or `AUTO_DEV_DIFF_BASE` only when neither exists.
- Treat `--workflow` and `AUTO_DEV_WORKFLOW` as explicit overrides; do not let the infer script silently replace them.
- Confirm the workflow targets the dev environment for the current branch only.

## Reporting
- Summarize changes and commands run.
- Provide quick verification steps when applicable.
