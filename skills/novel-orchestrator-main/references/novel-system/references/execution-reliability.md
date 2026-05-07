# Execution Reliability

把 sub-agent 当成会失败的执行层，而不是神奇黑盒。
稳定性来自更小的 scope、更短的输出契约和明确的退化规则。

## Default Limits

- 完整章节审计：`1 chapter / dispatch`
- 多章节请求：先 `triage`，不要直接逐章详审
- 章节规划：`1 chapter / dispatch`
- 章节扩写或大修：`1 chapter` 或 `1 dominant scene chain / dispatch`
- 长时间并行任务：默认不超过 `2`

## Compact Output First

sub-agent 默认先返回结构化结果：

- `status`
- `score_total`
- `blockers`
- `targeted_fix_list`
- `decision`

解释要短，先把可执行信息交回来，再补分析。

## Timeout Recovery Ladder

1. `single wait`
   - 只做一次正常等待，不忙轮询
2. `scope reduction`
   - 超时后优先把任务砍小
   - 常见做法：
     - `5 chapters -> 2 chapters triage -> 1 chapter full audit`
     - `full prose critique -> compact scorecard`
     - `whole chapter rewrite -> targeted revision`
3. `single respawn`
   - scope 缩小后只重派一次
4. `approved fallback`
   - 第二次仍失败，只允许 analysis / summary / 轻量 repair 降级
   - 必须记录 `reason_code`
5. `quality guard`
   - timeout fallback 不能单独支持 canon 写回
   - 如仍有 blocker，停在 `needs_review`

## When To Refuse

遇到这些情况，宁可拆分或返回 `blocked`：

- 一个 agent 被要求完整评估很多章
- 输出格式开放、无上限
- 输入同时包含大量正文、状态和无关设定
- 任务既要生成又要审计还要总结

## Good Failure

好的失败不是“卡住直到没人管它”，而是：

- 明确标记超时
- 明确说明已尝试的 scope
- 明确给出下一次更小的 dispatch 方案
- 保住已通过的结果，不让迟到输出污染当前轮次
