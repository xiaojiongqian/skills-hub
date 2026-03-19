---
name: novel-bible-manager
description: 长篇小说设定与状态档案维护。用于维护和修订世界观、角色、势力、地点、规则、时间线、角色动态状态等结构化 canon；把零散创作笔记或章节事实沉淀到 WORLD.md、CHARACTERS.md、RULES.md、CHARACTER_ARCS.md、ARC_STATUS.md 等状态文件；区分静态设定与动态演进；处理设定冲突、档案压缩、条目规范化。当用户提到角色卡更新、设定整理、故事圣经维护、时间线条目、状态文件修订或 canon 冲突修复时触发。
---

# 设定档案维护

## Overview

只维护故事圣经和结构化状态，不负责整章正文写作。
把输入事实规范化为可检索、可更新、可比对的项目条目。

先把项目信息拆成静态设定、动态状态、开放回路、伏笔、最近事件。
不要把一切都堆进同一份角色档案。

## Accept This Input

优先接收契约化输入。
如果与 `novel-orchestrator-main` 配合，兼容其 `TaskEnvelope`。

最少需要：

- `task_type`
  - 推荐使用 `story-bible-update`、`character-state-update`、`current-state-sync`
- `objective`
- `scope`
  - 指明项目、arc、章节、涉及实体
- `context_bundle`
  - 至少提供相关 canon 片段和本次新事实来源
- `constraints`
  - 说明哪些文件可改，哪些只是参考
- `expected_outputs`
  - 说明需要条目草案、冲突清单还是 change set

## Work in This Order

1. 识别来源事实
   - 区分“已进入正文的事实”“用户刚确认的设定”“仍属候选的想法”
2. 做静态 / 动态分流
   - 静态信息进入 `WORLD.md`、`CHARACTERS.md`、`FACTIONS.md`、`LOCATIONS.md`、`RULES.md`
   - 动态信息进入 `CHARACTER_ARCS.md`、`ARC_STATUS.md`、`RECENT_EVENTS.md`、`CURRENT_STATE.md`
3. 做实体归一化
   - 统一 id、命名、章节引用、相关实体
4. 做冲突检查
   - 检查是否和既有规则、时间线、角色背景或已知秘密冲突
5. 输出最小变更集
   - 优先返回条目 patch 和 change set，不整份覆盖大文件

## Preserve Canon Hygiene

始终遵守这些边界：

- 把静态设定和动态状态分开
- 把“角色本质”与“角色当前处境”分开
- 把“正文中已证实”与“规划中预期”分开
- 把“开放回路”与“已解决事实”分开

如果事实证据不足，不要硬写入 canon。
如果多个来源冲突，先返回冲突诊断和候选修复，不要擅自裁决。

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 例如角色条目草案、世界规则条目、时间线条目、状态条目
- `diagnostics`
  - 冲突、不确定项、证据不足项
- `recommendations`
  - 建议同步哪些文件
- `proposed_writebacks`
  - 仅给建议，不直接假定写回
- `change_set`
  - 任何状态修改都尽量返回 diff 风格条目

适合返回的 artifact 类型：

- `character_entry`
- `character_state_entry`
- `world_rule_entry`
- `timeline_entry`
- `arc_state_entry`
- `current_state_patch`

## Refuse Scope Creep

不要直接写章节正文。
不要直接设计整章戏剧结构，除非任务只是把既定事实整理进大纲。
不要把未获确认的脑暴内容写成 canon。
不要在缺少事实来源时补完隐含设定。

## Shared References

- `references/novel-system/conventions.md`
- `references/novel-system/schemas/character.schema.md`
- `references/novel-system/schemas/current-state.schema.md`
- `references/novel-system/references/context-hygiene.md`
