# Smoke File Guide

## Contract

This skill expects a smoke test case document. If no source document exists,
stop and tell the user to provide one that includes:
- environment
- accounts or auth
- `1+` suite with `1+` case per suite

Point to these starter templates when helpful:
- [../assets/minimal-smoke.md](../assets/minimal-smoke.md)
- [../assets/minimal-smoke.yaml](../assets/minimal-smoke.yaml)

## Pick the source

Prefer:
1. file path from the user
2. latest project smoke artifact
3. repo doc already structured as smoke suites and cases

Accepted formats:
- Markdown
- text
- YAML
- JSON

If a file exists but is broader than a smoke doc, normalize only the smoke-relevant
subset into the smallest safe companion smoke file before running browser steps.

Ignore implementation details unless the source is intentionally technical.

## Required fields

Environment:
- base URL or environment label
- stable app verification signal when URL auto-detect may be used
- required setup, seed data, or feature flags when relevant

Accounts or auth:
- account role or durable label
- auth method
- handoff note when SSO, MFA, or CAPTCHA applies

Suites and cases:
- each suite has a clear name
- each suite may declare `default_account`
- each suite may distinguish default-required coverage from optional or on-demand coverage
- each case has route or page, minimal steps, and `expect`
- each case may declare `account` to override the suite default
- each case may declare or imply scope qualifiers such as `optional`, `on-demand`, `按需`, `专项`, `必跑`, or `常规必跑`

Preserve stable suite labels from the source when they are already clear, such
as `suite-2`. Do not rewrite them to aliases like `smoke-suite-2`.

Preferred Markdown shape:
- `## Environment`
- `## Accounts`
- `## Suite: <name>`
- `### Case: <name>`

Account resolution order:
1. `case.account`
2. `suite.default_account`
3. the only account in the document

If multiple accounts exist and no rule selects one, stop and ask the user to map
accounts to suites or cases, then write the verified mapping back.

## Living file rule

Treat the smoke file as a living artifact.

If a run is blocked, then becomes unblocked after clarification, auth, setup, or handoff:
- continue the run
- write back the smallest durable rule that would prevent the same block next time

If environment or account details were missing:
- try local discovery first
- ask the user only for missing durable facts when discovery fails
- write back the details only after the run proves they are correct

If URL auto-detect finds a responding app:
- treat the URL as a candidate
- verify it with the smoke doc's environment signal when available
- otherwise write it back only after at least one case passes on that app

## Write back only durable facts

Good write-backs:
- verified base URL or environment label
- stable app verification signal
- required setup, seed data, or feature flag note
- account role or durable account label
- auth method or stable handoff rule
- prerequisite such as logged-in state or seeded data
- clearer action wording
- missing success signal
- required step ordering
- stable handoff note such as CAPTCHA, MFA, or SSO

Do not write back:
- credentials, cookies, OTPs, or secrets
- private personal identifiers when a role or shared account label is enough
- transient outages or one-off incidents
- verbose debugging notes
- brittle selectors when user-visible wording works

## Compression rules

Keep edits compressed:
- one line per durable rule
- merge duplicates
- remove stale notes
- prefer one representative happy path over many near-duplicates
- keep one clear `expect` per case unless multiple outcomes are independently critical
- do not merge optional or on-demand cases into the default required path
- if a case succeeds only after exploratory clarification, rewrite the case with the clearer durable wording

## Minimal shape

Prefer Markdown unless another tool requires structured data.

Required information is:
- environment block
- accounts or auth block
- `1+` suite with `1+` case per suite

Each case must include:
- account when the suite is not single-role
- route or page
- minimal steps
- pass condition
