---
name: smoke-test
description: |
  MANUAL TRIGGER ONLY: invoke only when user types /smoke-test.
  Run browser-based smoke tests from a feature file, release checklist, or test plan.
  Convert the file into a small happy-path smoke plan, execute it with gstack browse,
  capture key screenshots plus console/network evidence, write a report, and tighten
  the smoke file when a recoverable blocker reveals missing durable context. Use when
  asked to "run a smoke test", "sanity check this deploy", or "test this from the spec".
---

# Smoke Test

Use this for fast critical-path browser verification from a smoke file. It is narrower
than `/qa` and `/qa-only`: test must-work paths, produce evidence, and do not fix app code.

Use other skills when they fit better:
- `/browse` for one-off browser checks
- `/qa-only` for broader exploratory QA without fixes
- `/qa` when the task includes fixing bugs

## Source And Scope

Pick the best source file:
- user-provided file
- latest `~/.gstack/projects/.../*-test-plan-*.md`
- repo doc with user-visible flows

Accepted sources: Markdown, text, YAML, JSON.

Extract only:
- route or page
- minimal happy-path steps
- pass condition
- auth or setup requirement

Ignore implementation details unless the source is intentionally technical.

Turn the source into `3-10` smoke flows. Collapse near-duplicates and prioritize:
- auth or landing page
- primary create/edit/submit flow
- critical search/filter/publish/checkout/share flow, if relevant

## Living Smoke File

Treat the source file as a living artifact.

If a blocker becomes recoverable after clarification, auth, setup, or handoff:
- continue the run
- patch the smoke file with the smallest durable rule that would prevent the same block next time

Write back only durable facts:
- prerequisite
- clearer action wording
- missing success signal
- required step ordering
- stable handoff note such as SSO, CAPTCHA, or MFA

Do not write back:
- credentials, cookies, OTPs, or secrets
- one-off incidents
- verbose debugging notes
- brittle selectors when user-visible wording works

Keep edits compressed: one rule per line, merge duplicates, remove stale notes.

## Run Summary

1. Read [execution](references/execution.md) before browser work.
2. Resolve the browse binary and target URL.
3. Handle auth through cookies, direct login, or handoff when needed.
4. Run each flow with the minimum happy-path actions.
5. Inspect `console --errors`, `network`, and `snapshot -D` at key transitions.
6. Mark each flow `PASS`, `FAIL`, `BLOCKED`, or `SKIPPED`.

Retry a failed interaction once before calling it a real failure.

## Progressive Disclosure

Read more only when needed:
- [smoke-file](references/smoke-file.md)
  Use when the source file is weak, too verbose, or needs write-back/compression rules.
- [execution](references/execution.md)
  Use for browse setup, target URL resolution, auth, run loop, and pass criteria.
- [reporting](references/reporting.md)
  Use for screenshot policy, report shape, and how to embed `screenshots/` links.
- [assets/minimal-smoke.md](assets/minimal-smoke.md)
  Copy when you want a human-friendly starter template.
- [assets/minimal-smoke.yaml](assets/minimal-smoke.yaml)
  Copy when you need structured smoke data.

## Reporting Basics

Always write:
- `"$REPORT_DIR/smoke-report.md"`
- `"$REPORT_DIR/smoke-summary.json"`

Report bundles live under `.gstack/smoke-reports/<yyyymmdd-hhmm>-<suite-slug>`.
Derive `suite-slug` from the selected smoke source or explicit suite label, then
slug it to lowercase kebab-case. If the same minute and suite collide, append
`-2`, `-3`, and so on.

`smoke-report.md` should contain:
- source file and target URL
- assumptions
- source updates made during the run
- summary table
- one flow record per flow
- console/network summary
- final status

Keep the report easy to scan:
- prefer Markdown source unless another tool requires structured data
- usually keep `1-2` screenshots per flow
- embed screenshots directly inside the matching flow record
- use relative links like `screenshots/<file>.png`
- do not dump screenshots into a separate appendix

## Core Rules

- Do not modify application source code, tests, or CI files
- The only non-report file this skill may edit is the smoke file, or a safe companion smoke file if the original is read-only
- Keep scope to critical browser happy paths
- If the smoke file and live app disagree, report the mismatch instead of guessing
- Stop after `3` blocker-level failures unless the user asks to continue
- If the user wants fixes, hand off to `/qa`

## Example Requests

- `Use $smoke-test on docs/release-smoke-checklist.md against http://localhost:3000`
- `Use $smoke-test on spec/editor-smoke.md and tighten the file if a recovered blocker reveals missing durable context`
