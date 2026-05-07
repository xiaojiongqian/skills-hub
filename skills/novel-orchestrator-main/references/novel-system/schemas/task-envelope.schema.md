# TaskEnvelope Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
session_id: "novel-project-session"
task_id: "task-001"
parent_task_id: "task-000"
agent_role: "plot_planner"
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
  timeout_budget_ms: 60000
  max_attempts: 2
input_snapshot:
  snapshot_id: "snapshot-001"
  ref: "workflows/CHXXX/01-context.md"
  blocks: ["current_state", "open_loops", "recent_chapter_summaries"]
  source_refs: ["CURRENT_STATE.md", "OPEN_LOOPS.md", "summaries/CHXXX.summary.md"]
extensions:
  reliability:
    output_contract: "compact-structured"
    max_chapters_in_scope: 1
    scope_reduction_required_on_retry: true
  quality_loop:
    workflow_mode: "quality-council-loop"
    council_id: "CHXXX-qc"
    round_index: 1
    phase: "audit"
    seat_id: "story_engine_seat"
    seat_task_type: "quality-seat-story-engine"
    review_isolation: "blind-seat-audit"
    peer_visibility: "blind"
    seat_context_snapshot_ref: "workflows/CHXXX/quality/round-1/story-engine-context.md"
    owned_dimensions: ["opening_hook", "core_event", "escalation"]
    locked_dimensions: []
    counterforce_seat_id: ""
    previous_round_ref: "workflows/CHXXX/quality/round-0.json"
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
  - 包括 timeout budget 和最大尝试次数
- `input_snapshot`
  - 固定本次 role/sub-agent 允许消费的上下文快照
- `extensions`
  - 未来扩展字段的 namespaced 容器
  - `extensions.quality_loop` 推荐承载：
    - `workflow_mode`
    - `council_id`
    - `round_index`
    - `phase`
    - `seat_id`
    - `seat_task_type`
    - `review_isolation`
    - `peer_visibility`
    - `seat_context_snapshot_ref`
    - `owned_dimensions`
    - `locked_dimensions`
    - `counterforce_seat_id`

说明：

- `executor_mode` 推荐值：
  - `subagent`
  - `approved-fallback`
  - `orchestrator`
- 严格模式下，且用户或运行环境明确允许 sub-agent 时，标准章节 workflow 的 role task 可使用 `subagent`
- 普通模式下，在主线程内串行切换 role pack，并把 `executor_mode` 标为 `orchestrator` 或 `approved-fallback`
