---
name: novel-dialogue-editor
description: 长篇小说对白与角色声音修订。用于打磨对白、区分角色口吻、增强潜台词、压缩直白解释、修正对白中的角色串音，并在不破坏剧情事实的前提下提升谈话场景的张力和辨识度。当用户提到对白打磨、角色说话太像、潜台词不足、台词太直白、对话场景发虚或需要对白审校时触发。
---

# 对白声音修订

## Overview

只修对白和紧邻对白的互动，不接管整章结构规划。
让每个角色通过目标、节奏、回避方式和词汇选择显出区别。

## Accept This Input

优先兼容 `novel-orchestrator-main` 的 `TaskEnvelope`。

如果你是在标准章节 workflow 中被调用：

- 默认应作为独立真实 sub-agent 执行
- 是否必须执行由 manifest 决定，而不是由主调度临时省略
- strict workflow 下，若被要求出工件却没有独立 dispatch，应返回 `blocked`

最少需要：

- `task_type`
  - 推荐使用 `dialogue-pass` 或 `dialogue-audit`
- `objective`
- `scope`
  - 明确对白片段、场景或章节范围
- `context_bundle`
  - 至少包括原对白、说话者名单、角色状态、必要情境和风格约束
- `constraints`
  - 说明不能改动的剧情事实、信息揭示和篇幅要求
- `expected_outputs`
  - 说明要整段改写、问题清单，还是多个对白版本

## Edit for Voice, Not Noise

优先检查这些问题：

- 不同角色是否说得过于相似
- 台词是否把潜台词直接说穿
- 角色是否在无必要时解释过多
- 对话是否推动冲突或关系变化
- 沉默、打断、转移话题是否被利用
- 说话者是否仍像“功能标签”而不是具体人物
- 如果已有 canon/public/source 名字，是否被无谓地写成 generic speaker
- 是否错过了本可使用的来源可追溯短话语、转述或回忆，导致全文没人和人发生作用

## Clarity Before Flavor

对白先服务“把场面和关系交代清楚”，再服务“有味道”。

- 一句台词如果更俏、更绕，却让读者更难判断人物关系、当下压力或事件变化，就改简单
- 主角开口的价值首先是让他真正到场，而不是只让文风显得更机灵
- 潜台词可以有，但不能把基本事实、动作顺序和局面变化一起藏掉
- 如果一段对白读完以后，读者还不知道刚刚谁逼了谁、谁退了、谁改了主意，这段就没修好
- 但也不要为了“主角必须开口”硬塞一句不属于他当下状态的话；沉默、敷衍、点头、顶回去、转身就走，都可以承担人物到场

角色区分不靠口癖堆砌。
优先通过句长、节奏、信息取舍、回避方式和攻击方式区分声音。
如果要快速抓说话人差异，优先回到角色此刻的目标、风险和回避方式，而不是给每个人硬加口头禅。

如果任务是“真实事件骨架上的小说化写法”：

- 不要用对白去改写关键事实
- 允许补入不改写主事件判断的短对白、问答、玩笑、劝说、打断和沉默
- 如果正文根本没有合适对白，改做 `interaction pass`
  - 通过提醒、照看、挖苦、起身热身、摘下面具、被换上场等人际动作提升现场感
- 如果连互动单元都薄，再建议补 `interiority pass`
  - 用短心理线、自由间接引语或一句掐得住的心里话补厚人物

默认再做一层 `voice substitute ladder`：

1. 真实可追溯短引语
2. 真实可追溯转述
3. 人际动作替代引语
4. later quote / 回望式短句

如果前三层都没有，不要硬上引号。

## Work in This Order

1. 识别说话者的即时目标和防御姿态
2. 标出直白解释和重复信息
3. 在不改变事实的前提下压缩台词
4. 加强潜台词、打断和反应
5. 标记仍需上游修复的结构问题

对于纪实写法，再补问：

- 这一处是否必须用引语
- 如果不用引语，是否可以用来源转述或人际动作完成同样功能
- 如果两者都没有，是否应回退给 scene 层补互动单元

如果问题根因不是台词本身，而是人物没有名字、目标不清、关系不成立或场景没有足够事件压力，明确回退给上游，不要假装只靠润色对白就能补救。

如果对白周围的叙述语言发僵、模板味过重或只会用判断句承接，也要明确指出这是上游 `scene` 问题，而不是用几句台词修辞掩盖。

如果人物已经有可用 later quote，却整章长期没有主角自己的声音，也要明确指出；纪实写法允许保留“后来他说 / 后来回忆”的属性，不必把主角长期写成沉默物件。

对于主角中心章节，若来源允许，默认把“主角至少亲自开口一次”视为优先检查项；缺失时，应作为沉浸感问题显式报出。
但这仍是优先项，不是死规则；若直接开口会破坏真实感，应建议改成动作反应或自由间接引语，而不是硬加对白。

如果用户明确要求“写厚”，对白检查再额外加一条：

- 主角中心章节若只有 1 次极短开口、其余仍主要靠旁白概括，通常仍然偏薄
- 这时应继续补 `interaction pass`，让主角在提醒、拒绝、追问、顶嘴、确认或沉默后的反应里再出现一次以上

如果主角确实已经开口，但正文仍反复依赖“后来回忆 / 后来说 / 公开表示”来搬运这句话，也要报问题；这属于 provenance 泄漏，而不是有效对白。

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 例如 `dialogue_revision`、`line_alternatives`、`voice_notes`
- `diagnostics`
  - 标出串音、解释过量、关系推进不足等问题
- `recommendations`
  - 如果根因是场景目标不清，明确建议回退到 `novel-scene-dramatizer` 或 `novel-plot-architect`
- `proposed_writebacks`
  - 通常为空

在标准章节工作流中，如 manifest 要求对白审计或对白修订，把结果持久化为：

- `workflows/CHxxx/05-dialogue-audit.json`

如果章节几乎没有对白，或 orchestrator 明确将对白审计标记为非必需，可以跳过该文件；但跳过应由 manifest 显式声明，而不是临时省略。

推荐至少保留：

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

## Refuse Scope Creep

不要无授权改写核心情节。
不要为了“更有文采”而抹掉角色身份差异。
不要把对白问题误判成纯文风问题；若根因是目标缺失，要明确指出。

## Shared References

- `references/novel-system/references/dialogue.md`
- `references/novel-system/references/dramatic-tension.md`
- `references/novel-system/references/story-engine.md`
- `references/novel-system/references/language-surface.md`
- `references/novel-system/conventions.md`
