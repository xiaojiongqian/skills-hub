---
name: novel-continuity-auditor
description: 长篇小说连续性与一致性审计。用于审查章纲、场景草稿、章节草稿或状态文件是否与既有设定、时间线、角色动机、知识边界、开放回路、伏笔和主题约束一致；输出结构化风险清单、严重度、证据和修复建议；适合作为并行评估子 skill 使用。当用户提到连续性检查、设定打架、时间线矛盾、角色动机不通、伏笔遗失或跨章节一致性审查时触发。
---

# 连续性审计

## Overview

专注发现问题，不默认重写正文。
把判断压缩成可排序、可证据追溯、可修复的结构化审计结果。

## Accept This Input

优先兼容 `novel-orchestrator-main` 的 `TaskEnvelope`。

最少需要：

- `task_type`
  - 推荐使用 `continuity-audit`、`character-consistency-audit`、`timeline-audit`
- `objective`
- `scope`
  - 明确待审对象
- `context_bundle`
  - 至少包括待审文本或大纲、当前状态、相关章节摘要、关键设定和角色状态
- `constraints`
  - 说明审计重点和允许忽略的维度
- `expected_outputs`
  - 要求 findings、severity、evidence 和 fix 建议

## Audit by Dimension

默认检查这些维度：

- 世界规则
- 时间线与空间连续性
- 角色动机与成长阶段
- 知识边界
- 开放回路延续
- 伏笔使用与回收窗口
- 主题与风格偏移

如果输入不足以判断某一维度，明确标成 `blocked` 或低置信度，不要装作确定。

## Work in This Order

1. 列出待审对象和证据范围
2. 逐维度比对相关 state / summary / canon
3. 对每个问题给严重度、置信度和证据
4. 提出最小修复建议
5. 如果问题来自上游规划缺口，明确指出应回退到哪个 skill

## Return Structured Output

至少返回：

- `status`
- `artifacts`
  - 通常为 `audit_report`
- `diagnostics`
  - 每条 findings 都应带 `analysis_dimension`、`severity`、`confidence`、`evidence_refs`
- `recommendations`
  - 建议重写正文、回退到规划、更新状态文件，或仅做轻微修补
- `proposed_writebacks`
  - 通常为空，或只建议更新审计记录

如果没有发现问题，明确返回空 findings，并说明残余风险来自哪里。

## Refuse Scope Creep

不要在未被要求时重写整章。
不要把审计意见伪装成 canon。
不要跳过证据，直接说“感觉不对”。

## Shared References

- `references/novel-system/contracts.md`
- `references/novel-system/references/continuity-check.md`
- `references/novel-system/references/context-hygiene.md`
