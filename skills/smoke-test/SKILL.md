---
name: smoke-test
description: |
  MANUAL TRIGGER ONLY: invoke only when user types /smoke-test.
  Run browser-based smoke tests from a required smoke test document.
  Validate that the document includes environment, account/auth prerequisites,
  and suites with test cases. Recover missing durable context through
  auto-detection or concise user questions, verify it, then write the
  verified non-secret facts back to the smoke document. Execute with gstack
  browse, capture key screenshots plus console/network evidence, write a
  report, and tighten the smoke file when a recoverable blocker reveals
  missing durable context. Use when asked to "run a smoke test", "sanity
  check this deploy", or "test this from the spec".
---

# Smoke Test

Use this for fast critical-path browser verification from a smoke test document.
It is narrower than `/qa` and `/qa-only`: test must-work paths, produce evidence,
and do not fix app code.

Use other skills when they fit better:
- `/browse` for one-off browser checks
- `/qa-only` for broader exploratory QA without fixes
- `/qa` when the task includes fixing bugs

## Input Contract

This skill requires a smoke test case document. If no document is provided or
discoverable, stop and tell the user the contract below. Point them to the
starter templates instead of inventing cases from scratch.

Accepted sources: Markdown, text, YAML, JSON.

The document should define:
- environment: base URL or environment label, plus any required seed data, feature flags, setup, and preferably one stable app verification signal
- accounts/auth: which role or durable account label to use, how auth is satisfied, and stable handoff notes such as SSO, CAPTCHA, or MFA
- suites: `1+` suite with `1+` case per suite

Each case should define:
- account selection when the suite can run under multiple roles
- route or page
- minimal happy-path steps
- expected success state

Equivalent headings or keys are fine. Prefer `Environment`, `Accounts`, `Suite`,
and `Case`.

Account resolution order is:
1. `case.account`
2. `suite.default_account`
3. the only account defined in the smoke document

If multiple accounts exist and none of the rules above selects one, stop and ask
the user to clarify the durable account mapping, then write the verified mapping
back into the smoke document.

If the user hands over a broader spec, normalize only the smoke-relevant subset
into a smoke file or safe companion smoke file before running browser steps.

## Source And Scope

Pick the best source file:
- user-provided smoke file
- latest project smoke artifact
- repo doc already structured as smoke suites and cases

Extract only:
- target environment
- auth or account requirement
- suite and case happy path
- pass condition

Ignore implementation details unless the source is intentionally technical.

Turn the source into `3-10` smoke cases. Collapse near-duplicates and prioritize:
- auth or landing page case
- primary create/edit/submit case
- critical search/filter/publish/checkout/share case, if relevant

Group related cases under a clear suite label.

## Living Smoke File

Treat the source file as a living artifact.

If a blocker becomes recoverable after clarification, auth, setup, or handoff:
- continue the run
- patch the smoke file with the smallest durable rule that would prevent the same block next time

If environment or account context is missing:
- try stable local evidence first: URL auto-detect, existing logged-in state, cookies, or repo docs
- if still blocked, ask the user only for the missing durable facts
- validate the answer by reaching the target URL or authenticated state successfully
- then write the verified non-secret facts back into the smoke file

If URL auto-detect finds a live candidate:
- treat it as a candidate URL, not a verified URL
- verify it with an environment signal from the smoke file when available
- otherwise require at least one passing smoke case on that app before writing the URL back

Write back only durable facts:
- verified base URL or environment label
- stable app verification signal
- required seed data, flags, or setup note
- account role or durable account label
- auth method or stable handoff note
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
- private personal identifiers when a role or shared account label is enough

Keep edits compressed: one rule per line, merge duplicates, remove stale notes.

## Run Summary

1. Read [smoke-file](references/smoke-file.md) when the contract or write-back rules are unclear.
2. Read [execution](references/execution.md) before browser work.
3. Validate the source document contract. If no smoke document exists, stop with the contract requirements and starter template links.
4. Resolve the browse binary and target URL.
5. Fill missing environment or auth context through auto-detection first, then concise user questions only when needed.
6. Validate recovered context. Persist a detected URL only after an environment signal matches or at least one smoke case passes on that app.
7. Write back the durable non-secret facts and any clarified case wording, then continue the run.
8. Run each suite and case with the minimum happy-path actions.
9. Inspect `console --errors`, `network`, and `snapshot -D` at key transitions.
10. Mark each case `PASS`, `FAIL`, `BLOCKED`, or `SKIPPED`, then roll up suite and overall status.
11. If a case passes with notable interaction difficulty, capture that friction in the report.

Retry a failed interaction once before calling it a real failure.

## Progressive Disclosure

Read more only when needed:
- [smoke-file](references/smoke-file.md)
  Use when the source contract is weak, too verbose, needs normalization, or needs write-back/compression rules.
- [execution](references/execution.md)
  Use for browse setup, contract validation, account resolution, target URL resolution, auth, run loop, and pass criteria.
- [reporting](references/reporting.md)
  Use for screenshot policy, suite/case report shape, interaction friction notes, and how to embed `screenshots/` links.
- [assets/minimal-smoke.md](assets/minimal-smoke.md)
  Copy when you want a human-friendly starter template that matches the contract.
- [assets/minimal-smoke.yaml](assets/minimal-smoke.yaml)
  Copy when you need structured smoke data that matches the contract.

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
- summary table by suite and case
- one case record per case, grouped by suite
- interaction friction notes for passed-but-hard cases
- console/network summary
- final status

Keep the report easy to scan:
- prefer Markdown source unless another tool requires structured data
- usually keep `1-2` screenshots per case
- embed screenshots directly inside the matching case record
- use relative links like `screenshots/<file>.png`
- do not dump screenshots into a separate appendix

## Core Rules

- Do not modify application source code, tests, or CI files
- The only non-report file this skill may edit is the smoke file, or a safe companion smoke file if the original is read-only or too broad for durable smoke rules
- Keep scope to critical browser happy paths
- If the smoke file and live app disagree, report the mismatch instead of guessing
- Stop after `3` blocker-level failures unless the user asks to continue
- If environment or account info cannot be validated, stop as `NEEDS_CONTEXT` instead of inventing inputs
- If a case description is unclear but the run reveals a durable clearer wording, update the smoke document and record that source update in the report
- If the user wants fixes, hand off to `/qa`

## Example Requests

- `Use $smoke-test on docs/release-smoke.md against http://localhost:3000`
- `Use $smoke-test on spec/editor-smoke.md, ask me for missing account context if needed, verify it, and write the durable notes back to the smoke file`
