# TaskEnvelope Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
session_id: "novel-project-session"
task_id: "task-001"
parent_task_id: "task-000"
agent_role: "novel-plot-architect"
task_type: "chapter-plan"
objective: "Plan CH012 so the protagonist chooses betrayal over silence"
priority: "normal"
scope:
  project_id: "glass-city"
  arc_id: "arc-02"
  chapter_id: "CH012"
  scene_ids: []
  entity_refs: ["char-lin", "char-shen"]
context_bundle: {}
constraints: {}
expected_outputs: {}
write_back_policy: {}
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
