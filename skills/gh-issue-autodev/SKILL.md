---
name: gh-issue-autodev
description: >
  End-to-end GitHub issue execution in the current repository with gh CLI. Use
  when the user asks to handle a specific issue number: fetch and classify the
  issue (feature, bug, task), pause for clarification if ambiguous, decompose
  complex work, implement changes, run context-aware quality checks (lint,
  tsc/typecheck, unit/integration tests), and automatically run the
  `playwright` skill for UI validation when necessary, then commit and push
  the current branch.
---

# GitHub Issue Auto Dev

## Overview

Resolve one GitHub issue completely in the current repository from intake to pushed commit.

## Inputs

- `issue_number` (required)
- Optional constraints from user (scope boundaries, deadlines, must-have behavior)

If `issue_number` is missing, ask for it and stop until provided.

## Workflow

1. Preflight checks
- Confirm repo context with `pwd`, `git rev-parse --show-toplevel`, and `git rev-parse --abbrev-ref HEAD`.
- If branch is `main` or `dev`, stop and ask the user to switch to a working branch.
- Run `gh auth status`; if unauthenticated, ask the user to run `gh auth login` first.

2. Load and understand the issue
- Run `gh issue view <issue_number> --json number,title,body,labels,assignees,state,url`.
- Classify the issue: requirement, defect, or other task.
- Extract acceptance criteria, constraints, and edge cases.

3. Ambiguity gate
- If expected behavior, scope, or acceptance criteria is ambiguous, ask the user concise clarification questions.
- Do not start implementation until ambiguities are resolved.

4. Decompose when needed
- If work is non-trivial (multi-module, high-risk, or multi-step), produce a short execution plan and then implement step-by-step.

5. Implement the fix or feature
- Make only necessary changes tied to the issue.
- Keep diffs small and focused.

6. Verify quality
- Pick checks based on changed surface area:
- Frontend/TS changes: run lint + typecheck + relevant tests.
- Backend/functions changes: run lint + unit/integration tests for impacted modules.
- Build/config changes: run impacted build and validation commands.
- Automatically run the [`$playwright`](../playwright/SKILL.md) skill when UI validation is necessary, and verify critical user paths.
- Do not use Playwright MCP for this workflow.
- Escalate to [`$playwright-interactive`](../playwright-interactive/SKILL.md) only when the issue requires persistent local browser state across edits, repeated reloads, or Electron validation.
- For authenticated TaleDraw or TaleLens console UI checks, first run `source "$HOME/.config/taledraw-test.env"` when the file exists. Then prefer `TALEDRAW_TEST_EMAIL` and `TALEDRAW_TEST_PASSWORD`; if they are unset, fall back to `TALELENS_TEST_EMAIL` and `TALELENS_TEST_PASSWORD`. If env vars are still missing, use Keychain (`codex-talelens-test-email` / `codex-talelens-test-password`). Do not hardcode credentials in repo files.

7. Commit and push
- Review with `git status` and a focused diff summary.
- Commit using Conventional Commits with issue context.
- Push only the current branch: `git push origin <current-branch>`.

8. Final report
- Return issue URL, problem summary, implemented changes, verification commands/results, and commit SHA.
- If any check could not run, state why and list residual risk.

## Command Snippets

- `gh issue view <issue_number> --json number,title,body,labels,assignees,state,url`
- `gh issue view <issue_number> --web`
- `git rev-parse --abbrev-ref HEAD`
- `git status`
