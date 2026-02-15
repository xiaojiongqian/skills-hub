---
name: firebase-gcp-debug
description: Debug Firebase and Google Cloud issues (emulators, Cloud Functions v1/v2, Firestore/Auth/Storage) using `firebase` and `gcloud` CLIs. Use when investigating Firebase 部署/函数报错, emulator 启动失败, Firestore 权限/索引问题, or when you need to query GCP Cloud Logging / Cloud Run logs for Firebase-backed services.
---

# Firebase + GCP Debug

## Triage (always)

- Decide target: local emulators vs deployed (prod/staging)
- Identify `projectId` (usually from `.firebaserc` / `firebase.json`)
- Identify function/service name, region, and exact timestamp of the failure (UTC if possible)
- Collect the full error text + any request id / trace id

## Local emulator workflow

1. Confirm tooling versions:
   - `node --version`
   - `firebase --version`
2. Start only what you need (faster, less noise):
   - `firebase emulators:start --only functions,firestore`
3. For Node debugging, enable inspector:
   - `firebase emulators:start --only functions --inspect-functions`
4. Reproduce the issue and watch emulator logs.
5. If the bug depends on Firestore rules/data, run with a known dataset:
   - Use emulator import/export (`--import` / `--export-on-exit`) when available in the repo.

## Deployed (prod) workflow

### 1) Verify auth + project selection

- Firebase CLI:
  - `firebase login:list`
  - `firebase projects:list`
  - `firebase use <projectId>`
- gcloud:
  - `gcloud auth list`
  - `gcloud config set project <projectId>`

### 2) Find the right runtime (v1 vs v2)

- Prefer `firebase functions:list` first.
- If it’s Functions v2, logs are typically under Cloud Run (Cloud Logging `resource.type="cloud_run_revision"`).

### 3) Read logs (Cloud Logging)

Use tight filters: project, resource type, service/function name, and timestamp window.

- Functions v2 / Cloud Run service logs (most common for v2):
  - `gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="<service>" AND timestamp>="<ISO8601>"' --limit 100`
- Functions v1 logs:
  - `gcloud logging read 'resource.type="cloud_function" AND resource.labels.function_name="<function>" AND timestamp>="<ISO8601>"' --limit 100`

Tips:
- Add `severity>=ERROR` to narrow failures.
- If you have a trace id, add `trace="projects/<projectId>/traces/<traceId>"`.

## Firestore/Auth/Storage quick checks

- Firestore permission issues:
  - Confirm rules target (emulator vs deployed)
  - Check `PERMISSION_DENIED` logs and the affected document path
- Index errors:
  - Errors usually include a console link to create the missing index
- Auth:
  - Validate token audience/project mismatch (`aud`, `iss`, `project_id`)

## TaleDraw repo shortcuts (this repo)

- Client UI: `cd client && npm run dev`
- Callable Functions (func-core): `cd func-core && npm run serve`
- Web-tier functions: `cd functions-web && npm run serve`
- End-to-end emulators: run `firebase emulators:start` at repo root

## Codex sandbox notes

- Any command that reaches the network (Firebase/GCP APIs, `gcloud`, `firebase`) may require approval.
- When running such commands, request escalation and include a 1-sentence justification.

## Safety

- Never paste service account JSON keys into chat; use a file path and redact sensitive fields.
- Prefer least-privilege roles and short-lived credentials.
