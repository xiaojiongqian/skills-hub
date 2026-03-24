# Contracts

本系统中所有 skill 之间的协作，都应建立在可扩展、版本化、可校验的契约上。

## Core Rules

- 使用统一 envelope
- 给关键契约加版本号
- 严格校验核心字段
- 允许新增可选字段
- 忽略未知非核心字段
- 对不合格输出优先拒收、修复或重试
- 把 workflow 状态契约和子 skill 结果契约分开
- 把 provenance、execution、input snapshot 作为一等公民，而不是临时备注

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
  - 子 skill 输出封套
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

当 workflow 声明 `require_subagents: true` 时，还至少检查：

- `execution_policy`
- `required_dispatches`
- `trace_file`
- `dispatches`
- `exceptions`
- artifact 的 `task_id` 是否能在 execution trace 里找到
- required role 的 dispatch 是否真实以 `subagent` 完成，或拥有被允许且被登记的 fallback

若输出为 `blocked`、`invalid` 或 `needs_review`，默认不直接写回全局状态。
