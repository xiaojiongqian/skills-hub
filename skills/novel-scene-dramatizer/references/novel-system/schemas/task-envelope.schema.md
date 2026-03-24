# TaskEnvelope Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
session_id: "novel-project-session"
task_id: "task-001"
parent_task_id: "task-000"
agent_role: "novel-plot-architect"
task_type: "chapter-plan"
objective: "Plan CHXXX around a visible threshold event that advances ARC-XX without resolving the primary conflict"
priority: "normal"
scope:
  project_id: "PROJECT_X"
  arc_id: "ARC-XX"
  chapter_id: "CHXXX"
  scene_ids: []
  entity_refs: ["char-a", "char-b"]
context_bundle: {}
constraints: {}
expected_outputs: {}
write_back_policy: {}
provenance:
  orchestrator_task_id: "orch-001"
  upstream_artifacts: ["workflows/CHXXX/01-context.md"]
execution:
  run_id: "run-001"
  attempt: 1
  started_at: "2026-03-21T10:00:00Z"
  executor_mode: "subagent"
input_snapshot:
  snapshot_id: "snapshot-001"
  ref: "workflows/CHXXX/01-context.md"
  blocks: ["current_state", "open_loops", "recent_chapter_summaries"]
  source_refs: ["CURRENT_STATE.md", "OPEN_LOOPS.md", "summaries/CHXXX.summary.md"]
extensions: {}
```

必填字段：

- `schema_version`
- `contract_version`
- `session_id`
- `task_id`
- `agent_role`
- `task_type`
- `objective`
- `scope`
- `context_bundle`
- `expected_outputs`
- `write_back_policy`

增强字段：

- `provenance`
  - 说明任务由谁调度、继承了哪些上游工件
- `execution`
  - 说明这次调用的执行方式、attempt 和时间戳
- `input_snapshot`
  - 固定本次子 skill 允许消费的上下文快照
- `extensions`
  - 未来扩展字段的 namespaced 容器

说明：

- `executor_mode` 推荐值：
  - `subagent`
  - `approved-fallback`
  - `orchestrator`
- 严格模式下，标准章节 workflow 的子 skill task 默认应使用 `subagent`
