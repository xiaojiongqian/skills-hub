---
name: novel-chapter-summarizer
description: 长篇小说章节摘要与状态沉淀。用于把章节草稿或定稿压缩成最小可传递上下文，生成章节摘要、最近事件条目、当前状态补丁、开放回路变化和伏笔变化草案；帮助主 skill 在不灌输全文的前提下向后续章节传递记忆。当用户提到章节摘要、最近事件提取、上下文压缩、状态同步草案或归档后摘要时触发。
---

# 章节摘要沉淀

## Overview

只做压缩、提取和状态整理，不负责创造新剧情。
把正文变成后续步骤可消费的最小记忆单元。

## Accept This Input

优先兼容 `novel-orchestrator-main` 的 `TaskEnvelope`。

最少需要：

- `task_type`
  - 推荐使用 `chapter-summary`、`current-state-sync`、`open-loop-update`
- `objective`
- `scope`
  - 明确章节范围
- `context_bundle`
  - 至少包括目标章节或稳定草稿、当前状态、相邻章节摘要、相关回路条目
- `constraints`
  - 说明摘要粒度、是否允许状态推断
- `expected_outputs`
  - 说明需要摘要、recent events、state patch 或 loop delta

## Summarize for Forward Use

优先提取这些内容：

- 一句话章节摘要
- 关键 beats
- 实际发生的状态变化
- 新增 / 推进 / 回收的开放回路
- 新埋或兑现的伏笔
- 下一章必须承接的义务

不要做剧情复述。
不要把细节越写越长。

## Work in This Order

1. 从正文中提取可确认事实
2. 区分“发生了什么”和“这意味着什么”
3. 压缩成摘要与事件条目
4. 推导最小状态变更
5. 标明哪些内容可写回，哪些只适合提醒

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 例如 `chapter_summary`、`recent_event_entries`、`current_state_patch`
- `diagnostics`
  - 标出不确定的解释、信息缺口、需要人工确认的状态变化
- `recommendations`
  - 建议同步哪些状态文件
- `proposed_writebacks`
  - 建议更新 `summaries/`、`RECENT_EVENTS.md`、`CURRENT_STATE.md`、`OPEN_LOOPS.md`、`FORESHADOWS.md`
- `change_set`
  - 当摘要已明确引出状态变化时，返回最小 diff

## Refuse Scope Creep

不要替正文补写新桥段。
不要把自己的推测当成既成事实。
不要输出一份比原章还长的“摘要”。

## Shared References

- `references/novel-system/context-model.md`
- `references/novel-system/schemas/chapter-summary.schema.md`
- `references/novel-system/templates/chapter-summary.template.md`
- `references/novel-system/templates/CURRENT_STATE.template.md`
