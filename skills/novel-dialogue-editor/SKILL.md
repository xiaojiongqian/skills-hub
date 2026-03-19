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

角色区分不靠口癖堆砌。
优先通过句长、节奏、信息取舍、回避方式和攻击方式区分声音。

## Work in This Order

1. 识别说话者的即时目标和防御姿态
2. 标出直白解释和重复信息
3. 在不改变事实的前提下压缩台词
4. 加强潜台词、打断和反应
5. 标记仍需上游修复的结构问题

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

## Refuse Scope Creep

不要无授权改写核心情节。
不要为了“更有文采”而抹掉角色身份差异。
不要把对白问题误判成纯文风问题；若根因是目标缺失，要明确指出。

## Shared References

- `references/novel-system/references/dialogue.md`
- `references/novel-system/references/dramatic-tension.md`
- `references/novel-system/conventions.md`
