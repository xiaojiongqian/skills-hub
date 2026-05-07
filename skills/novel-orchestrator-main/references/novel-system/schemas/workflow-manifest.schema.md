# WorkflowManifest Schema

```yaml
schema_version: "1.1"
contract_version: "2026-03"
chapter_id: "CHXXX"
chapter_title: "Chapter Title"
status: "initialized"
required_steps:
  continuity_audit: true
  dialogue_audit: false
execution_policy:
  orchestration_mode: "single-skill-role-subagents"
  require_subagents: true
  trace_file: "09-execution-log.json"
  dispatch_budget:
    max_parallel_dispatches: 2
    max_chapters_per_dispatch:
      continuity_audit: 1
      dialogue_audit: 1
      chapter_plan: 1
      chapter_draft: 1
      chapter_summary: 2
    default_wait_budget_ms: 60000
    max_respawns_per_dispatch: 1
    require_scope_reduction_on_retry: true
  required_dispatches:
    - agent_role: "plot_planner"
      output_refs: ["02-plan.json"]
      when: "always"
    - agent_role: "scene_writer"
      output_refs: ["03-draft.md"]
      when: "always"
    - agent_role: "continuity_gate"
      output_refs: ["04-continuity-audit.json"]
      when: "required_steps.continuity_audit"
    - agent_role: "voice_editor"
      output_refs: ["05-dialogue-audit.json"]
      when: "required_steps.dialogue_audit"
    - agent_role: "memory_summarizer"
      output_refs: ["07-summary.json"]
      when: "always"
  fallback_policy:
    allow_modes: ["approved-fallback"]
    allowed_reason_codes:
      - "env-no-subagent-support"
      - "subagent-timeout"
      - "subagent-no-response"
    require_exception_entry: true
    deny_writeback_on_timeout_fallback: true
notes: "Do not archive until lint passes."
```

说明：

- `execution_policy.require_subagents: true`
  - 表示标准章节 workflow 默认必须用真实 sub-agent
- `required_dispatches`
  - 定义了哪些角色在当前 workflow 中是门禁要求
- `when`
  - 当前仅推荐：
    - `always`
    - `required_steps.<name>`
- `fallback_policy.allow_modes`
  - `approved-fallback` 只能在 policy 允许且 trace 已登记 exception 时使用
- `dispatch_budget`
  - 限制并行度、单次 dispatch 章节数、等待预算和重派次数
