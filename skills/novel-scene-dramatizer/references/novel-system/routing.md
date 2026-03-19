# Routing

## Task Routing Matrix

- 设定整理、canon 修订、角色状态归档
  - `novel-bible-manager`
- 卷纲、arc、大纲、章纲、scene beats
  - `novel-plot-architect`
- 依据既定大纲扩写场景或章节
  - `novel-scene-dramatizer`
- 对白优化、角色口吻区分、潜台词增强
  - `novel-dialogue-editor`
- 连续性、时间线、动机、知识边界审计
  - `novel-continuity-auditor`
- 摘要压缩、recent events、state patch
  - `novel-chapter-summarizer`

## Serial vs Parallel

默认串行。
只有在多个任务共享同一输入快照，且不会互相污染状态时才并行。

必须串行的典型链路：

1. 读状态
2. 产出规划
3. 扩写正文
4. 审计草稿
5. 修订草稿
6. 生成摘要
7. 同步状态

适合并行的典型链路：

1. 对同一草稿并行做连续性审计和对白诊断
2. 对同一大纲并行给多个场景方案
3. 对同一章节并行产出多个分析维度的 findings

## Standard Chapter Workflow

1. 读取 `INDEX.md` 和 `CURRENT_STATE.md`
2. 加载相关状态与必要设定
3. 调用 `novel-plot-architect`
4. 调用 `novel-scene-dramatizer`
5. 并行调用 `novel-continuity-auditor` 与 `novel-dialogue-editor`
6. 汇总并修订
7. 调用 `novel-chapter-summarizer`
8. 由 `novel-orchestrator-main` 决定写回

## Standard Task Types

- 规划类
  - `master-outline`、`arc-plan`、`chapter-plan`、`scene-beats`、`reveal-plan`
- 生成类
  - `scene-draft`、`chapter-draft`、`dialogue-pass`、`prose-revision`、`chapter-summary`
- 审计类
  - `continuity-audit`、`character-consistency-audit`、`timeline-audit`、`dialogue-audit`
- 状态更新类
  - `story-bible-update`、`current-state-sync`、`open-loop-update`、`foreshadow-update`
