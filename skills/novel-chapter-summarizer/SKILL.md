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

如果你是在标准章节 workflow 中被调用：

- 默认应作为独立真实 sub-agent 执行
- 你的输出需要能被 runner 自动渲染
- 如果主调度没有独立 dispatch，却直接伪造 `07-summary.json`，在 strict workflow 下应返回 `blocked`

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
  - 默认要求：不要做无来源的人名补全、角色个性诊断或演员式拼接
- `expected_outputs`
  - 说明需要摘要、recent events、state patch 或 loop delta

## Summarize for Forward Use

优先提取这些内容：

- 一句话章节摘要
- 可观察的关键事件 / 决定 / 反转 beats
- 实际发生的状态变化
- 新增 / 推进 / 回收的开放回路
- 新埋或兑现的伏笔
- 下一章必须承接的义务

不要做剧情复述。
不要把细节越写越长。

## Preserve Concrete Story Memory

摘要不是主题评论，也不是把一章压成几个抽象判断。
先把事情压清楚，再压短；先让后续步骤容易读懂，再谈摘要是否漂亮。

默认保留这些信息：

- 谁在场
- 谁做了什么
- 哪个动作或事件改变了局面
- 后果落在谁身上
- 下一章必须接住什么具体余波
- 哪个物件、号码、空间或互动单元最能帮助后续章节记住这一章
- 如果存在 bounded interiority，哪一句 later quote 或心理线索最值得继续带着走
- 哪个 `scene cell` 最能代表本章
  - 它的 anchor、interaction 和 residue 分别是什么

如果 public/canon/source 已给出人物名字，优先直接保留名字。
如果来源没有名字，不要虚构；使用稳定角色标签，并保留可观察区分点。

尤其注意：

- `one_line_summary` 应写明本章真正发生的门槛事件或局面变化，不要只写主题
- `major_beats` 应保留具体事件锚点、具名人物和场面节点，不要写成“人物进一步成长”“关系继续变化”这类空话
- `state_changes` 应只写被正文明确支持的变化，不把性格判断当状态变化
- `carry_forward` 应写明未完成义务、后果和风险，而不是空泛展望
- 如果一章的真正力量来自章末余波，`carry_forward` 必须把那股压力保留下来，不要只剩事件年表
- 如果一章有来源可追溯的短话语、转述或人际动作，这些内容应尽量进入 `major_beats` 或 `carry_forward`，避免后续只记得结果不记得场面
- 如果一章的主角心理线主要靠 bounded interiority 成立，摘要里应保留那条 later quote 或最低限度心理方向，不要只保留外部事件
- 如果一章的故事感主要来自某个互动单元或某个被打断的动作，摘要里应保留这个动作链，不要把它压成结果句
- 如果用户要求正文“写厚”，摘要默认至少保留 1 个主角回应节点和 1 个互动链，不要把这些内容重新压平为赛季综述
- 生成 `summaries/`、`RECENT_EVENTS`、`CURRENT_STATE` 的人类可读文本时，避免把正文再改写成“后来回忆 / 后来说 / 根据资料”式的纪实表面
- 来源与 truth-boundary 约束可以留在后台诊断或证据层；人类可读摘要优先保留场面记忆、压力线和人物回应
- 如果压缩后需要靠读者自己重排时间顺序、因果顺序或人物位置，说明摘要压坏了，应回退重写

如果原章本身过于概述、导致很难提炼出清晰事件锚点，应在 `diagnostics` 中明确指出，提醒 orchestrator 回退到上游重写，而不是替正文发明细节。

如果原章的语言表面过于模板化、空心过桥句太多，导致事件锚点总被判断句盖住，也应在 `diagnostics` 中明确指出。

## Work in This Order

1. 从正文中提取可确认事实
2. 先做 evidence-backed event ledger，列出具名人物、稳定角色标签、关键场面锚点与互动单元
3. 区分“发生了什么”和“这意味着什么”
4. 压缩成摘要与事件条目
5. 推导最小状态变更
6. 标明哪些内容可写回，哪些只适合提醒

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 例如 `chapter_summary`、`recent_event_entries`、`current_state_patch`
- `diagnostics`
  - 标出不确定的解释、信息缺口、需要人工确认的状态变化
- 标出 unsupported inference、角色指代不稳、事件锚点不足等风险
- 标出是否把原章里的互动单元、主角开口或关键动作链压丢了；这类压缩失真会直接影响后续章节的小说感连续性
- `recommendations`
  - 建议同步哪些状态文件
- `proposed_writebacks`
  - 建议更新 `summaries/`、`RECENT_EVENTS.md`、`CURRENT_STATE.md`、`OPEN_LOOPS.md`、`FORESHADOWS.md`
- `change_set`
  - 当摘要已明确引出状态变化时，返回最小 diff

在标准章节工作流中，把结构化结果持久化为 `workflows/CHxxx/07-summary.json`。
正式的人类可读摘要文件 `summaries/CHxxx.summary.md` 应由 orchestrator 在确认写回后生成或更新。

推荐 `07-summary.json` 至少保留：

- `schema_version`
- `contract_version`
- `task_id`
- `task_type`
- `agent_role`
- `status`
- `execution`
- `artifacts`
- `diagnostics`
- `recommendations`
- `proposed_writebacks`
- `change_set`

推荐 `chapter_summary` artifact 的 `content` 使用稳定结构，方便 workflow runner 自动渲染：

- `one_line_summary`
- `major_beats`
- `actor_refs`
- `state_changes`
- `open_loops`
  - `opened`
  - `advanced`
  - `resolved`
- `carry_forward`

推荐 `diagnostics` 尽量保留：

- `analysis_dimension`
- `confidence`
- `evidence_refs`
- `note`

## Refuse Scope Creep

不要替正文补写新桥段。
不要把自己的推测当成既成事实。
不要输出一份比原章还长的“摘要”。
不要借摘要之名夹带人物性格判词、主题结论或作者解释。

## Shared References

- `references/novel-system/context-model.md`
- `references/novel-system/references/story-engine.md`
- `references/novel-system/references/story-quality.md`
- `references/novel-system/schemas/chapter-summary.schema.md`
- `references/novel-system/templates/chapter-summary.template.md`
- `references/novel-system/templates/CURRENT_STATE.template.md`
