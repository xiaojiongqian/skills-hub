# ArtifactResult Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
task_id: "task-001"
agent_role: "novel-continuity-auditor"
status: "needs_review"
artifacts: []
diagnostics: []
recommendations: []
proposed_writebacks: []
change_set: {}
```

状态枚举：

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
