# Reporting Guide

Write:
- `"$REPORT_DIR/smoke-report.md"`
- `"$REPORT_DIR/smoke-summary.json"`

Name `REPORT_DIR` as `.gstack/smoke-reports/<yyyymmdd-hhmm>-<suite-slug>`.
Use the smoke source filename stem as the default suite name, or an explicit suite
label when the user provided one. If the directory already exists, append `-2`,
`-3`, and so on until it is unique.

## Screenshot policy

Keep screenshots sparse and evidence-driven.

Usually use `1-2` screenshots per case:
- one key operation surface
- one final success, failure, or blocked state

Use fewer when one image already proves the result.
Use more only when the extra image materially improves the evidence.

Avoid screenshot spam:
- do not capture every click or field fill
- if two images are nearly identical, keep the stronger one

## smoke-report.md

Include:
- source file
- target URL
- assumptions
- source updates made during the run
- summary table by suite and case
- one case record per case, grouped by suite
- interaction friction notes for passed cases when relevant
- console/network summary
- final status: `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_CONTEXT`

Structure:
1. short summary table
2. per-suite sections with per-case records, with screenshots embedded inside the matching case record

Do not dump screenshots into a separate appendix.

Use relative Markdown image links under `screenshots/`:

```md
## Suite: Creator critical path

### Case: Create storyboard

Status: PASS
Route: /create
Expectation: storyboard editor appears
Account: creator

![Create storyboard start](screenshots/create-storyboard-start.png)
![Create storyboard end](screenshots/create-storyboard-end.png)

Friction: Publish entry point was below the fold and easy to miss on the first pass.
Source update: Clarified that the publish action is in the lower right toolbar.
Notes: No console errors. Generate completed successfully.
```

Keep screenshot links local to the report bundle:
- save images to `"$REPORT_DIR/screenshots"`
- link them as `screenshots/<file>.png`
- do not use absolute paths in `smoke-report.md`

## smoke-summary.json

Include:
- source
- url
- source_updates
- friction_cases
- totals by status
- failed cases
- blocked cases

## User-visible evidence

After generating screenshots, show the key PNGs to the user with the local image viewer tool.
