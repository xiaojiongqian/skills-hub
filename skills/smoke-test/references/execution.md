# Execution Guide

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

If nothing responds, ask the user for the URL.

## Auth

If auth is required:
- prefer `/setup-browser-cookies`
- or log in directly if the user supplied credentials
- use `"$B" handoff ...` and `"$B" resume` for CAPTCHA, MFA, or complex SSO

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

For each flow:
1. `goto` the route
2. `snapshot -i`
3. capture a start screenshot only if it adds value
4. execute the minimum happy-path actions
5. inspect `console --errors`, `network`, and `snapshot -D` at key transitions
6. capture the end, failure, or blocked state
7. mark the flow `PASS`, `FAIL`, `BLOCKED`, or `SKIPPED`

Retry a failed interaction once before calling it a real failure.

Useful browse patterns:
- `snapshot -i`
- `snapshot -C`
- `wait --networkidle`
- `responsive ...` only when responsive behavior is part of the smoke scope

## Pass criteria

Each flow should verify the applicable basics:
- page loads
- primary control is usable
- core action completes
- expected success state is visible
- no meaningful new console errors appear
- no obviously broken network request blocks the action

If the source is vague, the minimum smoke bar is:
- landing page works
- one primary action works
- user reaches the expected resulting state
