---
name: git-pr-merge
description: >
  Review, validate, and merge a GitHub pull request into a target branch with
  `gh` and `git`. Use when the user asks to merge a PR end-to-end, optionally
  delete the source branch, and optionally use a temporary worktree. Run
  autonomous review first; if blocking issues, unresolved conflicts, failed
  checks, or insufficient docs/tests are found, comment on the PR and stop
  instead of merging.
version: 1.1.0
license: MIT
metadata:
  short-description: Review and merge a GitHub PR safely
---

# Git PR Merge

## Overview

End-to-end pull request merge workflow: review the diff for quality, security, and docs/tests coverage, validate with local checks, handle simple conflicts automatically, merge, and clean up. Works with any GitHub-hosted repository regardless of language or branching model.

## Quick start

```text
Merge PR #123
Merge PR #456 into main, squash, and delete the source branch
Merge https://github.com/org/repo/pull/789 using a temporary worktree
```

## Inputs

- `pr`: required. PR number, `#123`, or full PR URL.
- `target_branch`: optional. Default `dev`. If the repo does not use `dev`, set explicitly.
- `merge_strategy`: optional. `merge` | `squash` | `rebase`. Default `merge`.
- `delete_branch`: optional. Default `false`.
- `use_worktree`: optional. Default `false`.

## Operating model

- Execute the full flow autonomously once the user requests a merge.
- Do not pause for routine confirmations during fetch, review, merge, test, push, cleanup, or PR comments.
- Stop only when a required input is missing, access is unavailable, or a blocking issue means the PR must not be merged.
- Never force-push.
- Never delete protected branches such as `main`, `master`, `dev`, or `develop`.
- If the merge flow fails after review has started, leave a traceable PR comment and stop cleanly.

## Preconditions

1. Confirm repo scope and remotes:
   - `pwd`
   - `git rev-parse --show-toplevel`
   - `git remote -v`
2. Verify GitHub CLI access:
   - `gh auth status`
3. Resolve the PR and capture metadata:
   - `gh pr view <pr> --json number,title,state,isDraft,headRefName,baseRefName,author,mergeable,commits,additions,deletions,body,url`
   - `gh pr checks <pr>`
   - `gh pr diff <pr>`
4. Determine the target branch:
   - If the user specified `target_branch`, use it.
   - Otherwise default to `dev`.

Do not continue if the PR is closed, already merged, inaccessible, or still in draft state.

## Review workflow

### Review mode

Choose review depth from total changed lines (`additions + deletions`):

- Small: `< 100`
- Medium: `100-500`
- Large: `> 500`

Always perform:

- code quality review
- security review
- docs and tests completeness review
- impact and regression review

If the host agent supports deeper review helpers or subagents, use them for medium and large PRs. If not, perform the review manually.

### Sub-agent delegation

For medium and large PRs, delegate review and post-merge simplification to sub-agents for deeper analysis:

- **Code review sub-agent**: Performs the detailed code quality, security, impact, and docs/tests review. Invoke after capturing the PR diff and metadata.
  - Claude: use the `code-reviewer` skill (or the Agent tool with a review prompt).
  - Other agents: use the bundled prompt at `<path-to-skill>/agents/code-reviewer.md` to spawn a sub-agent. Pass the PR diff and metadata as input.
- **Code simplifier sub-agent**: Reviews the merged code for duplication, dead code, and unnecessary complexity. Invoke after a successful merge, before the final push.
  - Claude: use the `simplify` skill (or the Agent tool with a simplification prompt).
  - Other agents: use the bundled prompt at `<path-to-skill>/agents/code-simplifier.md` to spawn a sub-agent. Pass the list of changed files and their post-merge content.

For small PRs, sub-agent delegation is optional — inline review is sufficient.

### Required review checks

1. Read the diff and identify the changed modules.
2. Check for obvious bugs, unsafe behavior, sensitive data, and risky edge cases.
3. Check whether docs and tests are adequate for the size and type of change.
4. Distinguish issues introduced by this PR from historical issues that already existed.

### Docs and tests policy

Use three modes:

- Strict mode:
  - for large PRs or obvious feature additions
  - require meaningful design or requirement documentation, either in changed docs, a sufficiently detailed PR body, or linked external docs
  - require tests for new public behavior
- Update mode:
  - for medium PRs
  - require doc/test updates when public behavior, interfaces, or contracts changed
- Consistency mode:
  - for small PRs
  - verify that existing docs and tests still match the new behavior

If docs or tests are clearly insufficient for the chosen mode, do not merge.

### Historical issues

If review finds problems that are clearly outside the PR diff and not introduced by this PR:

- do not block the merge for those issues alone
- optionally create a GitHub issue to track the historical debt
- note it in the PR summary comment

### Blocking issues

If review finds blocking issues, do all of the following:

1. Add a PR review comment describing:
   - the blocking problem
   - affected files or lines
   - concrete fixes needed
2. If the current user has permission and the repo workflow uses draft PRs, mark the PR back to draft:
   - `gh pr ready <pr> --undo`
   - Skip this step if the current user is not the PR author and does not have maintainer access.
3. Stop without merging.

Use a comment shape like:

```text
## PR merge blocked

**PR**: #<number> <title>
**Source → Target**: `<source_branch>` → `<target_branch>`
**Review mode**: <Small|Medium|Large> (<N> lines changed)

### Blocking issues
| # | File | Line(s) | Severity | Description |
|---|------|---------|----------|-------------|
| 1 | path/to/file | L42-L50 | critical | description |

### Docs/tests gaps
- <description, or "None">

### Conflict status
- <clean / N conflicts auto-resolved / N conflicts unresolvable — details>

### Next actions
1. specific fix instruction
2. ...
```

## Workspace preparation

Before switching branches:

1. Record the current branch:
   - `git rev-parse --abbrev-ref HEAD`
2. Check for local modifications:
   - `git status --porcelain`
3. If dirty, stash automatically:
   - `git stash push -m "pr-merge-<pr>-auto-stash"`

Restore the stash at the end if one was created.

## Target branch setup

### Default mode

Operate in the current worktree:

```bash
git fetch origin
git checkout <target_branch>
git pull --ff-only origin <target_branch>
```

### Worktree mode

If `use_worktree=true`, use a temporary worktree to avoid disturbing the current checkout:

```bash
temp_dir="/tmp/git-pr-merge-<pr>-$(date +%s)"
git fetch origin
git worktree add "$temp_dir" origin/<target_branch>
cd "$temp_dir"
```

If worktree creation fails, either recover cleanly or fall back to default mode only when it is safe to do so.

## Merge preparation

1. Check out the PR branch:
   - `gh pr checkout <pr>`
2. Return to the target branch if needed.
3. Test the merge without finalizing it yet (for `merge` strategy):
   - `git merge --no-commit --no-ff <source_branch>`

If the merge applies cleanly, continue to validation.

## Conflict handling

The default behavior is to resolve conflicts automatically. Attempt resolution for all conflict types:

- import list and dependency conflicts — combine both sides
- formatting-only and comment-only conflicts — accept the incoming change
- config file conflicts — merge both entries when semantically safe
- logic conflicts — read both sides, understand intent from the PR description and surrounding code, and produce a correct resolution

For each resolved conflict, record the file, the resolution strategy, and a brief rationale so it can be included in the post-merge comment.

Only abort when a conflict is genuinely unresolvable — for example, two sides fundamentally contradict each other with no way to determine the correct behavior from available context. In that case:

1. Abort the in-progress merge:
   - `git merge --abort`
2. Add a PR review comment listing each unresolved conflict with file paths and a description of why it cannot be auto-resolved.
3. If the current user has permission, mark the PR back to draft:
   - `gh pr ready <pr> --undo`
4. Stop without merging.

## Validation before merge

Run the smallest sufficient validation based on changed modules and repo tooling.

Preferred order:

1. lint or static checks
2. type checks
3. unit or integration tests for affected modules

Detect commands from the project when possible:

- Node: `npm run lint`, `npm run typecheck`, `npm test`, `npm run test:unit`
- Python: `ruff check .` or `flake8`, `mypy`, `pytest`
- Go: `go vet ./...`, `go test ./...`
- Rust: `cargo clippy`, `cargo test`

For monorepos or multi-package projects, prefer running checks only for affected packages or workspaces rather than the entire project. Look for workspace-level scripts (e.g., `nx affected`, `turbo run test --filter=...`, `pnpm --filter`).

If checks fail:

1. capture the failing command and error
2. comment on the PR with the failure summary
3. abort or reset the merge state:
   - `git merge --abort` or `git reset --hard HEAD`
4. if the current user has permission, mark the PR back to draft
5. stop without merging

## Finalize merge

When review and validation pass, finalize based on the chosen `merge_strategy`:

### Strategy: merge (default)

```bash
git merge --no-ff <source_branch> -m "Merge pull request #<pr> from <source_branch>

<pr_title>

Auto-merged by git-pr-merge skill"
```

### Strategy: squash

```bash
git merge --squash <source_branch>
git commit -m "<pr_title> (#<pr>)

Auto-merged by git-pr-merge skill"
```

### Strategy: rebase

```bash
git rebase <source_branch>
```

Note: rebase rewrites history on the target branch. Use only when the team convention expects it.

After committing:

1. Push the target branch:

```bash
git push origin <target_branch>
```

2. Verify the merge was recognized by GitHub:
   - `gh pr view <pr> --json state,merged`
   - If the PR state is not `MERGED`, the push did not close the PR automatically. In that case, report the discrepancy to the user and suggest manually closing or re-targeting the PR.

3. Verify the commit:
   - `git log origin/<target_branch> -1`

## Post-merge PR comment

Add a summary comment to the PR conversation regardless of whether the merge succeeded or failed. The comment must be clear, concise, and information-dense — no filler, every line carries signal.

Use a comment shape like:

```text
## PR merge <result>

**PR**: #<number> <title>
**Source → Target**: `<source_branch>` → `<target_branch>`
**Strategy**: <merge|squash|rebase>
**Merge commit**: `<sha>` (or "N/A" if not merged)

### Review
- Mode: <Small|Medium|Large> (<N> lines changed)
- Verdict: <PASS|BLOCK>
- Findings: <one-line summary, or "No issues">

### Docs/tests
- Policy: <Strict|Update|Consistency>
- Adequate: <yes|no — brief reason if no>

### Validation
- Commands run: `<cmd1>`, `<cmd2>`
- Result: <all passed | failed — command and error>

### Conflicts
- <None | N conflicts resolved (list files) | Unresolvable — aborted>

### Cleanup
- Source branch: <deleted|retained>
- Worktree: <removed|N/A>

### Follow-up
- <historical issues, linked GitHub issues, or "None">
```

Omit sections that are entirely empty or not applicable, but never omit Review, Validation, or the merge result.

## Branch cleanup

Delete the source branch only if `delete_branch=true` and it is not a protected branch.

Typical command:

```bash
git push origin --delete <source_branch>
```

Never delete `main`, `master`, `dev`, or `develop`.

## Cleanup

This skill is responsible for cleaning up resources it created during the merge flow. The source branch is not a resource created by this skill — its lifecycle is controlled by the `delete_branch` input, not by cleanup.

At the end:

- If a temporary worktree was created, always remove it:
  - `git worktree remove "$temp_dir"`
  - If removal fails (e.g., uncommitted files), force-remove with `git worktree remove --force "$temp_dir"` since the worktree is purely temporary and any useful state has already been pushed.
- Restore the original working directory.
- Switch back to the branch that was checked out before the merge flow started.
- Pop the auto stash if one was created:
  - `git stash pop`

If stash pop fails due to conflicts, warn the user and leave the stash intact for manual resolution.

## Final report

Report:

- PR number and title
- source and target branches
- merge strategy used
- review result
- docs/tests assessment
- validation commands run
- merge result
- cleanup result
- any follow-up items

## Bundled resources

- `agents/openai.yaml` — OpenAI-compatible agent UI metadata
- `agents/code-reviewer.md` — Sub-agent prompt for code review (used by non-Claude agents)
- `agents/code-simplifier.md` — Sub-agent prompt for post-merge simplification (used by non-Claude agents)
