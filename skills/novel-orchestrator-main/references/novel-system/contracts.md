# Contracts

本系统中所有 skill 之间的协作，都应建立在可扩展、版本化、可校验的契约上。

## Core Rules

- 使用统一 envelope
- 给关键契约加版本号
- 严格校验核心字段
- 允许新增可选字段
- 忽略未知非核心字段
- 对不合格输出优先拒收、修复或重试
- 把 workflow 状态契约和 role/sub-agent 结果契约分开
- 把 provenance、execution、input snapshot 作为一等公民，而不是临时备注
- 超时、重派、降级执行也属于一等执行事实，不能只留在聊天记录里

默认版本：

```yaml
schema_version: "1.0"
contract_version: "2026-03"
```

兼容策略：

- legacy 工件可以只满足旧的最小字段集
- 新 workflow 默认使用增强契约
- lint 应按 manifest 的 execution policy 决定是否启用增强校验
- 新增字段优先进入 `execution`、`provenance`、`input_snapshot`、`extensions`
- 避免继续在顶层无序扩张
- 质量闭环相关字段默认进入 `extensions.quality_loop`

## Contract Set

- `schemas/workflow-manifest.schema.md`
  - workflow 级状态与执行策略契约
- `schemas/execution-trace.schema.md`
  - workflow 内真实 sub-agent 调度痕迹
- `schemas/task-envelope.schema.md`
  - 任务输入外层封套
- `schemas/context-bundle.schema.md`
  - 命名上下文块
- `schemas/artifact-result.schema.md`
  - role/sub-agent 输出封套
- `schemas/change-set.schema.md`
  - 最小状态变更集
- `schemas/character.schema.md`
- `schemas/chapter-summary.schema.md`
- `schemas/open-loop.schema.md`
- `schemas/foreshadow.schema.md`
- `schemas/current-state.schema.md`

## Validation Focus

主 skill 至少检查：

- `schema_version`
- `contract_version`
- `task_id`
- `task_type`
- `agent_role`
- `status`
- `artifacts`
- `diagnostics`
- `recommendations`
- `proposed_writebacks`
- `execution`

当 workflow 显式声明并获准使用 `require_subagents: true` 时，还至少检查：

- `execution_policy`
- `required_dispatches`
- `trace_file`
- `dispatches`
- `exceptions`
- artifact 的 `task_id` 是否能在 execution trace 里找到
- required role 的 dispatch 是否真实以 `subagent` 完成，或拥有被允许且被登记的 fallback
- 如有 `timed_out` dispatch，是否记录了 recovery action、再次尝试或显式停机理由
- 如发生 timeout fallback，是否带 `degraded_execution` 和记名 reason code

若输出为 `blocked`、`invalid` 或 `needs_review`，默认不直接写回全局状态。

当 workflow 声明 `extensions.quality_loop.workflow_mode: quality-council-loop` 时，还至少检查：

- `council_id`
- `round_index`
- `phase`
  - `audit` / `repair` / `re-audit`
- 如为评分席位任务，必须带：
  - `seat_id`
  - `review_isolation`
    - 默认 `blind-seat-audit`
  - `peer_visibility`
    - 默认 `blind`
  - `seat_context_snapshot_ref`
  - `owned_dimensions`
- 如为 orchestrator 汇总结果，必须带：
  - `seat_scorecards`
  - `advisory_findings`
  - `council_round_reports`
  - `locked_dimensions`
  - `round_decision`
- 如为 `re-audit` 且发生 repair，推荐带：
  - `counterforce_seat_id`
- canonical score 只能来自各自 owner seat
  - 其他 seat 的跨维度意见只能进入 `advisory_scores`
- 首轮评分不应读取同轮 peer finding
  - 需要 peer 输入时，应等 seat 先独立交卷，再进入聚合或 `re-audit`
