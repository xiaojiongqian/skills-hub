# Contracts

本系统中所有 skill 之间的协作，都应建立在可扩展、版本化、可校验的契约上。

## Core Rules

- 使用统一 envelope
- 给关键契约加版本号
- 严格校验核心字段
- 允许新增可选字段
- 忽略未知非核心字段
- 对不合格输出优先拒收、修复或重试

默认版本：

```yaml
schema_version: "1.0"
contract_version: "2026-03"
```

## Contract Set

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
- `proposed_writebacks`

若输出为 `blocked`、`invalid` 或 `needs_review`，默认不直接写回全局状态。
