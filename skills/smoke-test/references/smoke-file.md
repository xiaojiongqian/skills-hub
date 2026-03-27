# Smoke File Guide

## Pick the source

Prefer:
1. file path from the user
2. latest project test-plan artifact
3. repo doc with user-visible flows

Accepted formats:
- Markdown
- text
- YAML
- JSON

Extract only:
- routes or pages
- happy-path actions
- pass conditions
- auth or setup requirements

Ignore implementation details unless the source is intentionally technical.

## Living file rule

Treat the smoke file as a living artifact.

If a run is blocked, then becomes unblocked after clarification, auth, setup, or handoff:
- continue the run
- write back the smallest durable rule that would prevent the same block next time

## Write back only durable facts

Good write-backs:
- prerequisite such as logged-in state or seeded data
- clearer action wording
- missing success signal
- required step ordering
- stable handoff note such as CAPTCHA, MFA, or SSO

Do not write back:
- credentials, cookies, OTPs, or secrets
- transient outages or one-off incidents
- verbose debugging notes
- brittle selectors when user-visible wording works

## Compression rules

Keep edits compressed:
- one line per durable rule
- merge duplicates
- remove stale notes
- prefer one representative happy path over many near-duplicates
- keep one clear `expect` per flow unless multiple outcomes are independently critical

## Minimal shape

Prefer Markdown unless another tool requires structured data.

When you need a starter file, copy one of:
- [../assets/minimal-smoke.md](../assets/minimal-smoke.md)
- [../assets/minimal-smoke.yaml](../assets/minimal-smoke.yaml)

Required information is minimal:
- shared prerequisites
- per-flow route
- minimal steps
- pass condition
