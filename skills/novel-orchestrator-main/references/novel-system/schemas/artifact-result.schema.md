# ArtifactResult Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
task_id: "task-001"
task_type: "continuity-audit"
agent_role: "novel-continuity-auditor"
status: "completed"
execution:
  mode: "subagent"
  trace_ref: "workflows/CHXXX/09-execution-log.json"
  provenance:
    agent_session_id: "agent-123"
    agent_run_id: "run-456"
    external_invocation_id: ""
  input_snapshot:
    context_refs: ["workflows/CHXXX/01-context.md", "workflows/CHXXX/03-draft.md"]
    context_hash: "sha256:..."
artifacts: []
diagnostics: []
recommendations: []
proposed_writebacks: []
change_set: []
extensions: {}
```

状态枚举：

- `ready`
- `completed`
- `skipped`
- `success`
- `partial_success`
- `blocked`
- `invalid`
- `needs_review`

要求：

- `artifacts` 为主产物
- `diagnostics` 为问题和风险
- `recommendations` 为主 skill 的下一步建议
- `proposed_writebacks` 为建议写回目标
- `execution` 为真实执行来源和输入快照

兼容说明：

- legacy 工件可只带旧的最小字段集
- 新 workflow 默认应带 `contract_version`、`task_id`、`recommendations`、`execution`
- `change_set` 允许两种形态：
  - 旧的数组形态
  - 新的对象形态
