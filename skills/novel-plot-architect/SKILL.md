---
name: novel-plot-architect
description: 长篇小说情节与结构规划。用于规划 master outline、arc、大纲、章纲、scene beats、冲突升级、信息揭示、伏笔布置和回收窗口；在主题、角色弧线和当前状态约束下提出可执行的结构方案；为 novel-scene-dramatizer 提供稳定输入。当用户提到卷纲、章纲、卡文求解、冲突升级、伏笔安排、结构优化或多方案构思时触发。
---

# 情节结构规划

## Overview

只规划结构，不直接承担大段正文写作。
把剧情设计成可持续推进的冲突系统，而不是事件堆叠。

## Accept This Input

优先兼容 `novel-orchestrator-main` 的 `TaskEnvelope`。

最少需要：

- `task_type`
  - 推荐使用 `master-outline`、`arc-plan`、`chapter-plan`、`scene-beats`、`reveal-plan`
- `objective`
- `scope`
  - 说明是全书、当前 arc、某章还是某个场景
- `context_bundle`
  - 至少包括当前状态、相关章节摘要、角色动态、开放回路、主题约束
- `constraints`
  - 说明必须保留和必须避免的剧情事实
- `expected_outputs`
  - 说明要单一方案还是多个候选方案

## Plan with Structural Obligations

无论规划粒度多小，都尽量回答这些问题：

1. 这一单元的目标是什么
2. 谁在追求这个目标
3. 阻力和代价是什么
4. 哪个选择推动了转折
5. 哪条信息被揭示、遮蔽或延迟
6. 结束时留下了什么未完成感

重大转折优先由角色选择推动，而不是巧合。
信息优先分层释放，而不是一次解释完。

## Work in This Order

1. 确认规划层级
   - 全书、arc、章节、场景 beat
2. 读取当前义务
   - 主题、角色弧线、开放回路、下一章义务、不可违背事实
3. 搭建冲突链
   - 目标、阻碍、升级、代价、余波
4. 安排信息释放
   - 哪些要揭示，哪些要延迟，哪些要埋种子
5. 标出后续依赖
   - 哪些内容会要求后续章节继续承接
6. 输出结构化计划
   - 必须可供 `novel-scene-dramatizer` 直接接续

## Generate Options Deliberately

当用户要求构思或存在明显岔路时，优先给 2 到 3 个清晰方案。
每个方案都要说明：

- 核心推进逻辑
- 对角色弧线的影响
- 对开放回路和伏笔的影响
- 主要风险

不要堆很多弱方案。
如果一个方案明显更优，明确说明原因。

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 例如 `master_outline`、`arc_plan`、`chapter_plan`、`scene_beats`、`reveal_plan`
- `diagnostics`
  - 说明结构风险、节奏风险、依赖缺口
- `recommendations`
  - 建议后续调用哪个 skill
- `proposed_writebacks`
  - 建议同步到哪些状态文件
- `change_set`
  - 如果规划改变了 arc 状态、开放回路或伏笔布置，给出最小变更集

## Refuse Scope Creep

不要跳过规划直接写整章正文。
不要擅自更新 canon 文件。
不要为了“更精彩”而打破主题、角色弧线或当前状态约束。

## Shared References

- `references/novel-system/routing.md`
- `references/novel-system/references/plotting.md`
- `references/novel-system/references/dramatic-tension.md`
- `references/novel-system/templates/chapter.template.md`
