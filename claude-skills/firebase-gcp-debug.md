---
name: firebase-gcp-debug
description: 使用 firebase/gcloud CLI 排查 Firebase 与 Google Cloud 问题（emulator、Functions v1/v2、Firestore/Auth/Storage、Cloud Logging）。当出现部署失败、函数报错、emulator 启动失败、Firestore 权限或索引问题时触发。
tools: Read, Bash, Grep, Glob, TodoWrite
model: inherit
---

# Firebase + GCP Debug

## Triage first
- 明确目标环境：本地 emulator 还是云端（dev/staging/prod）。
- 确认 `projectId`、函数/服务名、region、报错时间点（建议 UTC）。
- 收集完整错误信息和 trace/request id。

## Local emulator flow
1. 检查版本：`node --version`、`firebase --version`
2. 只启动必要组件：`firebase emulators:start --only functions,firestore`
3. Node 调试：`firebase emulators:start --only functions --inspect-functions`
4. 复现并观察日志；必要时用 import/export 固定数据集。

## Deployed flow
1. 认证与项目：`firebase login:list`、`firebase use <projectId>`、`gcloud auth list`
2. 判断 runtime：先 `firebase functions:list`，再区分 v1/v2。
3. 读日志（加时间窗 + severity 过滤）：
   - v2/Cloud Run: `resource.type="cloud_run_revision"`
   - v1: `resource.type="cloud_function"`

## Quick checks
- Firestore `PERMISSION_DENIED`: 核对规则、路径、auth 上下文。
- Index 错误: 按报错链接补建索引。
- Auth 错误: 检查 token 的 `aud`/`iss`/`project_id`。

## Safety
- 不在对话中粘贴 service account 私钥。
- 优先最小权限与短期凭证。
