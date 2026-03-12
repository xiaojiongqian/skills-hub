---
name: gh-address-comments
version: 1.0.0
license: MIT
description: Help address review/issue comments on the open GitHub PR for the current branch using gh CLI; verify gh auth first and prompt the user to authenticate if not logged in.
metadata:
  short-description: Address comments in a GitHub PR review
---

# PR Comment Handler

Guide to find the open PR for the current branch and address its comments with `gh` CLI.

Prereq: ensure `gh` is authenticated (for example, run `gh auth login` once), then run `gh auth status` with workflow/repo scopes so `gh` commands succeed. If your agent or sandbox blocks network/auth access, grant it before continuing.

## 1) Inspect comments needing attention
- Run `python "<path-to-skill>/scripts/fetch_comments.py"` to print all review threads and standalone comments on the PR.

## 2) Ask the user for clarification
- Number all the review threads and comments and provide a short summary of what would be required to apply a fix for it
- Ask the user which numbered comments should be addressed

## 3) If user chooses comments
- Apply fixes for the selected comments

Notes:
- If gh hits auth/rate issues mid-run, prompt the user to re-authenticate with `gh auth login`, then retry.
