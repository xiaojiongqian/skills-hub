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
  orchestration_mode: "multi-skill-subagents"
  require_subagents: true
  trace_file: "09-execution-log.json"
  required_dispatches:
    - agent_role: "novel-plot-architect"
      output_refs: ["02-plan.json"]
      when: "always"
    - agent_role: "novel-scene-dramatizer"
      output_refs: ["03-draft.md"]
      when: "always"
    - agent_role: "novel-continuity-auditor"
      output_refs: ["04-continuity-audit.json"]
      when: "required_steps.continuity_audit"
    - agent_role: "novel-dialogue-editor"
      output_refs: ["05-dialogue-audit.json"]
      when: "required_steps.dialogue_audit"
    - agent_role: "novel-chapter-summarizer"
      output_refs: ["07-summary.json"]
      when: "always"
  fallback_policy:
    allow_modes: []
    require_exception_entry: true
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
  - 空数组表示 fail closed
  - 如果未来允许 `approved-fallback`，必须同时登记 trace exception
