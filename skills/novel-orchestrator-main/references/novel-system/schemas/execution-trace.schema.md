# ExecutionTrace Schema

```yaml
schema_version: "1.0"
contract_version: "2026-03"
chapter_id: "CHXXX"
orchestrator_role: "novel-orchestrator-main"
status: "in_progress"
dispatches:
  - task_id: "CHXXX-plan-001"
    agent_role: "plot_planner"
    mode: "subagent"
    status: "completed"
    attempt: 1
    agent_session_id: "agent-123"
    agent_run_id: "run-456"
    input_refs: ["01-context.md"]
    output_refs: ["02-plan.json"]
    scope_slice: ["CHXXX"]
    wait_budget_ms: 60000
    started_at: "2026-03-21T10:00:00Z"
    completed_at: "2026-03-21T10:02:00Z"
    model: "gpt-5.3-codex"
    notes: ""
    extensions:
      quality_loop:
        council_id: "CHXXX-qc"
        round_index: 1
        phase: "audit"
        seat_id: "story_engine_seat"
        owned_dimensions: ["opening_hook", "core_event", "escalation"]
exceptions:
  - agent_role: "plot_planner"
    output_refs: ["02-plan.json"]
    fallback_mode: "approved-fallback"
    reason_code: "env-no-subagent-support"
    approved_by: "user"
    justification: "Temporary outage in sub-agent runtime"
  - agent_role: "continuity_gate"
    output_refs: ["04-continuity-audit.json"]
    fallback_mode: "approved-fallback"
    reason_code: "subagent-timeout"
    approved_by: "workflow-policy"
    justification: "Retry also timed out after scope reduction"
    mitigation:
      - "split-scope"
      - "compact-output-contract"
    writeback_restriction: "no-canon-writeback-from-timeout-fallback"
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
- `status`
  - 推荐值：
    - `completed`
    - `timed_out`
    - `canceled`
    - `failed`
- `exceptions`
  - 只在 manifest fallback policy 允许时使用
  - 没有 exception，就不能把非 `subagent` 的 required dispatch 视为合法
- `extensions.quality_loop`
  - 用来标记某次 dispatch 属于哪个 council round、哪个 seat、哪个 phase
