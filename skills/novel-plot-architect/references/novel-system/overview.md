# Overview

这套系统的目标不是一次性写出某一章，而是以工程化方式支持长篇小说的长期创作。

它要解决的问题是：

- 世界观一致
- 角色成长与行为一致
- 设定可追踪、可更新、可检索
- 章节之间有延续性
- 伏笔与回收有秩序
- 张力与信息揭示可以持续设计
- 长周期创作中的上下文膨胀和遗忘尽量受控

## Core Principles

- 把小说项目视为有状态系统，而不是一次次独立对话
- 把正文与状态文件分开维护
- 让主 skill 成为唯一全局状态协调者
- 让子 skill 只处理单一职责
- 让上下文按层级渐进披露
- 让 skill 间协作建立在契约而不是默契上

## System Boundary

这套系统默认包含一个主 skill 和多个子 skill：

- `novel-orchestrator-main`
- `novel-bible-manager`
- `novel-plot-architect`
- `novel-scene-dramatizer`
- `novel-dialogue-editor`
- `novel-continuity-auditor`
- `novel-chapter-summarizer`

主 skill 负责调度、汇总和写回。
子 skill 负责在明确边界内产出结构化结果。
