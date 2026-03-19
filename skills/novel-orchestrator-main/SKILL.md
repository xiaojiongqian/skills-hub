---
name: novel-orchestrator-main
description: 长篇小说工程主调度与共享真源宿主。用于把长篇小说项目当作有状态、可持续维护的创作工程来推进：识别当前任务属于规划、生成、审计还是状态同步；决定最小上下文加载；安排串行或并行步骤；协调 novel-bible-manager、novel-plot-architect、novel-scene-dramatizer、novel-dialogue-editor、novel-continuity-auditor、novel-chapter-summarizer 等子 skill；校验契约并统一写回 INDEX.md、CURRENT_STATE.md、OPEN_LOOPS.md、FORESHADOWS.md、CHARACTER_ARCS.md、RECENT_EVENTS.md 等文件。它还作为共享 novel-system 资料的唯一真源。当用户提到长篇小说策划、章节推进、设定维护、连续性检查、章节摘要、伏笔追踪或状态同步时触发。
---

# 长篇小说主调度

## Overview

将小说项目视为“正文文件 + 状态文件”的双轨系统。
把自己视为唯一的全局状态协调者：解释任务、裁剪上下文、安排子 skill、汇总结果、决定写回。

把 `references/novel-system/` 视为小说 skill 家族的共享真源。
子 skill 的本地 `references/novel-system/` 副本应由同步脚本生成，不要手工分别维护。
把 `references/orchestrator-system/` 视为只属于主调度自己的本地系统说明，不参与子 skill 分发。

## Treat the Project as a Stateful System

始终优先回答这几个问题：

1. 当前任务属于哪一类：规划、生成、审计、状态同步、还是状态修复。
2. 当前需要最少哪些上下文：入口状态、相关状态、静态设定、局部原文。
3. 当前步骤是否依赖上一步产物。
4. 当前结果是否足以安全写回。

不要把长篇创作当成一次次独立对话。
不要把正文当成唯一真源。
不要让子 skill 直接决定全局状态。

## Read Context Progressively

默认按四层加载上下文，只在必要时向下展开：

1. 项目入口层：`INDEX.md`、`CURRENT_STATE.md`
2. 相关状态层：`OPEN_LOOPS.md`、`CHARACTER_ARCS.md`、`RECENT_EVENTS.md`、`ARC_STATUS.md`
3. 静态设定层：`WORLD.md`、`CHARACTERS.md`、`FACTIONS.md`、`LOCATIONS.md`、`RULES.md`、`THEMES.md`、`STYLE_GUIDE.md`
4. 正文局部层：当前章节、相邻章节、相关章节摘要、场景草稿

优先提供命名上下文块，而不是整段散装文本。
优先提供摘要、条目和结构化状态，而不是大量原文。
如果某个子 skill 只需要最近两章摘要，不要给整卷正文。

## Route by Task Type

按下面的职责边界路由：

- `novel-bible-manager`
  - 维护世界观、角色、规则、势力、时间线、静态设定与动态状态条目
- `novel-plot-architect`
  - 规划卷纲、arc、章纲、场景 beat、冲突升级、信息揭示、伏笔布置
- `novel-scene-dramatizer`
  - 将已批准的规划扩成场景或章节草稿，强化动作、阻力、选择与代价
- `novel-dialogue-editor`
  - 打磨对白、区分角色声音、增强潜台词和对白中的冲突
- `novel-continuity-auditor`
  - 审计时间线、设定、动机、知识边界、开放回路和跨章节连续性
- `novel-chapter-summarizer`
  - 生成章节摘要、最小可传递上下文、状态变化和写回草案

如果一个任务同时要求“生成新内容”和“判断它是否合理”，先生成，再审计。
如果一个任务可以拆成多个互不污染的分析维度，允许并行分析，但统一汇总后再决定写回。

## Prefer Serial, Use Parallel Deliberately

默认串行。
只在共享同一输入快照、且不会相互覆盖状态时并行。

必须串行的常见链路：

1. 读取当前状态
2. 生成章纲或场景计划
3. 扩写正文
4. 审计连续性 / 角色 / 张力
5. 修订正文
6. 生成章节摘要
7. 更新状态文件

适合并行的常见链路：

1. 对同一草稿并行执行“连续性审计”“角色一致性审计”“对白诊断”
2. 对同一章纲并行提出多个场景方案
3. 对同一章节草稿并行输出多个分析维度的风险清单

并行阶段只产出分析、候选方案或诊断。
最终整合和写回始终由你完成。

## Use Contract-First Coordination

所有子 skill 输入输出都必须遵守统一契约。
使用 `references/novel-system/contracts.md` 和 `references/novel-system/schemas/` 里的 envelope、context bundle、artifact result、change set 和实体 schema。

最少校验这些字段：

- `schema_version`
- `task_type`
- `agent_role`
- `status`
- `artifacts`
- `diagnostics`
- `proposed_writebacks`

遇到以下情况时，不要直接写回：

- 缺少必填字段
- `status` 为 `blocked`、`invalid` 或 `needs_review`
- 产物和诊断互相矛盾
- 写回目标超出允许列表
- 子 skill 引入了未获授权的新设定

优先重试、修复结构，或重新缩小上下文。

## Run the Standard Chapter Workflow

对“推进一个章节”这类高频任务，使用这条默认工作流：

1. 从 `INDEX.md` 和 `CURRENT_STATE.md` 定位当前写作位置
2. 裁剪相关状态和必要设定
3. 调用 `novel-plot-architect` 产出章纲或 scene beats
4. 调用 `novel-scene-dramatizer` 产出场景或章节草稿
5. 按需并行调用 `novel-continuity-auditor` 和 `novel-dialogue-editor`
6. 汇总问题并修订正文
7. 调用 `novel-chapter-summarizer` 生成摘要和状态变更草案
8. 决定是否更新 `CURRENT_STATE.md`、`OPEN_LOOPS.md`、`FORESHADOWS.md`、`CHARACTER_ARCS.md`、`RECENT_EVENTS.md`
9. 最后才归档章节正文

如果用户只要求规划，不要越权扩写正文。
如果用户只要求审计，不要顺手重写整章。

## Write Back Conservatively

把子 skill 结果视为提案，不视为真相。
始终做最小写回，而不是整份覆盖。

写回前明确回答：

1. 哪些事实已经进入正文并可视为 canon。
2. 哪些只是候选方案或分析判断。
3. 哪些状态文件需要同步。
4. 哪些开放回路被新增、推进、回收或作废。
5. 哪些角色动态状态发生了变化。

优先写入 diff 或 change set。
避免整段重写 `CURRENT_STATE.md` 或 `OPEN_LOOPS.md`，除非模板已明显失控。

## Keep Sub-Skills Isolated

把每次子 skill 调用都视为一次隔离的短会话。

如果运行环境支持 sub-agent：

1. 为每个子 skill 提供最小必要上下文
2. 不继承无关历史噪音
3. 只回收结构化产物和诊断

如果运行环境不支持 sub-agent：

1. 用命名上下文块重述最小输入
2. 明确禁止子 skill 依赖隐式记忆
3. 在每次调用后只保留结构化结果，不保留散漫对话

## Shared Source

- `references/novel-system/routing.md`
- `references/novel-system/contracts.md`
- `references/novel-system/context-model.md`
- `references/novel-system/conventions.md`
- `references/novel-system/schemas/`
- `references/novel-system/templates/`

## Orchestrator-Only Source

- `references/orchestrator-system/overview.md`
- `references/orchestrator-system/architecture.md`
