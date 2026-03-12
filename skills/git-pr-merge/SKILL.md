---
name: git-pr-merge
description: Review, validate, and merge a GitHub pull request into a target branch with `gh` and `git`. Use when the user asks to merge a PR end-to-end, optionally delete the source branch, and optionally use a temporary worktree. Run autonomous review first; if blocking issues, unresolved conflicts, failed checks, or insufficient docs/tests are found, comment on the PR and stop instead of merging.
version: 1.0.0
license: MIT
metadata:
  short-description: Review and merge a GitHub PR safely
---

# Git PR Merge

Use this skill to handle a pull request from review through merge in a repository-agnostic way.

## Inputs

- `pr`: required. PR number, `#123`, or full PR URL.
- `target_branch`: optional. Default `dev`.
- `delete_branch`: optional. Default `false`.
- `use_worktree`: optional. Default `false`.

If the repo does not use `dev`, set `target_branch` explicitly.

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
2. If appropriate for the repo workflow, run:
   - `gh pr ready <pr> --undo`
3. Stop without merging.

Use a comment shape like:

```text
## PR merge blocked

- Blocking issues:
  - ...
- Docs/tests gaps:
  - ...
- Next actions:
  1. ...
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
3. Test the merge without finalizing it yet:
   - `git merge --no-commit --no-ff <source_branch>`

If the merge applies cleanly, continue to validation.

## Conflict handling

Automatically resolve only conflicts that are clearly mechanical:

- import list conflicts
- formatting-only conflicts
- comment-only conflicts
- simple config merges where both sides can be safely combined

Do not auto-resolve complex logic conflicts, deletion-vs-modification conflicts, or behaviorally ambiguous merges.

If conflicts are too complex:

1. add a PR review comment summarizing the unresolved conflict
2. abort or reset the in-progress merge
3. optionally mark the PR back to draft
4. stop without merging

## Validation before merge

Run the smallest sufficient validation based on changed modules and repo tooling.

Preferred order:

1. lint or static checks
2. type checks
3. unit or integration tests for affected modules

Detect commands from the project when possible:

- Node: `npm run lint`, `npm run typecheck`, `npm test`, `npm run test:unit`
- Python: `pytest`
- Go: `go test ./...`
- Rust: `cargo test`

If checks fail:

1. capture the failing command and error
2. comment on the PR with the failure summary
3. abort or reset the merge state
4. optionally mark the PR back to draft
5. stop without merging

## Finalize merge

When review and validation pass:

1. Commit the merge if needed:

```bash
git commit -m "Merge pull request #<pr> from <source_branch>

<pr_title>

Auto-merged by git-pr-merge skill"
```

2. Push the target branch:

```bash
git push origin <target_branch>
```

3. Verify the result:
   - `git log origin/<target_branch> -1`
   - `gh pr view <pr> --json state,merged`

## Post-merge PR comment

Add a summary comment to the PR conversation with:

- target branch
- merge commit SHA
- whether conflicts occurred
- review outcome
- validation outcome
- any historical issues tracked separately
- whether the source branch was deleted

Keep it concise and traceable.

## Branch cleanup

Delete the source branch only if `delete_branch=true` and it is not a protected branch.

Typical command:

```bash
git push origin --delete <source_branch>
```

Never delete `main`, `master`, `dev`, or `develop`.

## Cleanup

At the end:

- remove the temporary worktree if one was used
- restore the original directory
- switch back to the original branch when appropriate
- pop the auto stash if one was created

If cleanup partially fails, report the remaining manual cleanup steps clearly.

## Final report

Report:

- PR number and title
- source and target branches
- review result
- docs/tests assessment
- validation commands run
- merge result
- cleanup result
- any follow-up items

## Examples

- `Merge PR #123 into dev`
- `Merge https://github.com/org/repo/pull/456 into main and delete the source branch`
- `Use git-pr-merge for PR 789 with a temporary worktree`
