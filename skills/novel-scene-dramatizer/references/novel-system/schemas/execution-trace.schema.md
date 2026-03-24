# ExecutionTrace Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
chapter_id: "CHXXX"
orchestrator_role: "novel-orchestrator-main"
status: "in_progress"
dispatches:
  - task_id: "CHXXX-plan-001"
    agent_role: "novel-plot-architect"
    mode: "subagent"
    status: "completed"
    agent_session_id: "agent-123"
    agent_run_id: "run-456"
    input_refs: ["01-context.md"]
    output_refs: ["02-plan.json"]
    started_at: "2026-03-21T10:00:00Z"
    completed_at: "2026-03-21T10:02:00Z"
    model: "gpt-5.3-codex"
    notes: ""
exceptions:
  - agent_role: "novel-plot-architect"
    output_refs: ["02-plan.json"]
    fallback_mode: "approved-fallback"
    reason_code: "env-no-subagent-support"
    approved_by: "user"
    justification: "Temporary outage in sub-agent runtime"
```

说明：

- `dispatches`
  - 记录每次真实调度
- `mode`
  - 推荐值：
    - `subagent`
    - `approved-fallback`
    - `orchestrator`
    - `legacy-inferred`
- `exceptions`
  - 只在 manifest fallback policy 允许时使用
  - 没有 exception，就不能把非 `subagent` 的 required dispatch 视为合法
