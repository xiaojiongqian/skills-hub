# Execution Guide

## Validate the contract

Before browser work:
1. confirm there is a smoke source file
2. confirm it includes environment, accounts or auth, and suites with cases, or can be safely normalized into a companion smoke file
3. if no smoke document exists at all, stop and tell the user the required contract plus starter template links

If environment or account fields are missing:
- try stable local discovery first
- only ask the user for missing durable facts when discovery fails
- after validation succeeds, patch the smoke file with the verified non-secret details

Resolve account selection before running a case:
1. use `case.account` when present
2. else use `suite.default_account` when present
3. else use the only account in the document
4. else stop and ask the user to clarify the mapping

## Resolve browse

```bash
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
GSTACK_ROOT="$HOME/.codex/skills/gstack"
[ -n "$_ROOT" ] && [ -d "$_ROOT/.agents/skills/gstack" ] && GSTACK_ROOT="$_ROOT/.agents/skills/gstack"
GSTACK_BROWSE="$GSTACK_ROOT/browse/dist"
B=""
[ -n "$_ROOT" ] && [ -x "$_ROOT/.agents/skills/gstack/browse/dist/browse" ] && B="$_ROOT/.agents/skills/gstack/browse/dist/browse"
[ -z "$B" ] && B="$GSTACK_BROWSE/browse"
if [ -x "$B" ]; then
  echo "READY: $B"
else
  echo "NEEDS_SETUP"
fi
```

If `NEEDS_SETUP`, ask first, then run:

```bash
cd "$GSTACK_ROOT" && ./setup
```

## Resolve target URL

Use:
1. user-provided URL
2. URL from the smoke file
3. local auto-detect

```bash
for url in http://localhost:3000 http://localhost:3001 http://localhost:4000 http://localhost:4173 http://localhost:8080; do
  "$B" goto "$url" >/dev/null 2>&1 && echo "$url" && break
done
```

If the smoke file had no verified URL and auto-detect succeeds, write the verified
base URL back into the smoke file only after verification. Verification order:
1. match an environment verification signal from the smoke file
2. or pass at least one smoke case on that app

Until then, treat it as a candidate URL. If nothing responds, ask the user for the URL.

## Auth

If auth is required:
- prefer `/setup-browser-cookies`
- or log in directly if the user supplied credentials
- use `"$B" handoff ...` and `"$B" resume` for CAPTCHA, MFA, or complex SSO

If the account or auth section is missing or vague:
- first infer from the smoke file, repo docs, and current logged-in state
- then ask the user for the missing durable facts: account role or label, auth method, and handoff expectations
- validate by reaching the authenticated state successfully
- write back only the role or label, auth method, and handoff note, never secrets

## Run loop

Create the report bundle:

```bash
SUITE_SOURCE="${SMOKE_SOURCE:-${SOURCE_FILE:-}}"
if [ -n "$SUITE_SOURCE" ]; then
  SUITE_RAW=$(basename "$SUITE_SOURCE")
  SUITE_RAW="${SUITE_RAW%.*}"
else
  SUITE_RAW="${SMOKE_SUITE:-suite}"
fi

SUITE=$(printf '%s' "$SUITE_RAW" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
[ -z "$SUITE" ] && SUITE="suite"

STAMP=$(date +%Y%m%d-%H%M)
REPORT_BASE=".gstack/smoke-reports/${STAMP}-${SUITE}"
REPORT_DIR="$REPORT_BASE"
N=2
while [ -e "$REPORT_DIR" ]; do
  REPORT_DIR="${REPORT_BASE}-${N}"
  N=$((N + 1))
done

mkdir -p "$REPORT_DIR/screenshots"
```

Use the chosen smoke source path as `SOURCE_FILE` when available. If the run has a
clear user-facing suite label that differs from the filename, set `SMOKE_SUITE`
first and let it win.

For each suite and case:
1. resolve the case account
2. `goto` the route
3. `snapshot -i`
4. capture a start screenshot only if it adds value
5. execute the minimum happy-path actions
6. inspect `console --errors`, `network`, and `snapshot -D` at key transitions
7. capture the end, failure, or blocked state
8. if the case passed but required retries, ambiguous controls, awkward scrolling, or workaround-like interaction, record a friction note for the report
9. if the case wording was unclear and the run established a durable clearer wording, patch the smoke file and record the source update
10. mark the case `PASS`, `FAIL`, `BLOCKED`, or `SKIPPED`

Retry a failed interaction once before calling it a real failure.

Useful browse patterns:
- `snapshot -i`
- `snapshot -C`
- `wait --networkidle`
- `responsive ...` only when responsive behavior is part of the smoke scope

## Pass criteria

Each case should verify the applicable basics:
- page loads
- primary control is usable
- core action completes
- expected success state is visible
- no meaningful new console errors appear
- no obviously broken network request blocks the action

A passing case may still carry a friction note when:
- the action was discoverable but awkward
- the happy path required a retry or non-obvious sequencing
- the UI wording or layout made the intended action hard to find

If the source is vague, the minimum smoke bar is:
- landing page works
- one primary case works
- user reaches the expected resulting state
