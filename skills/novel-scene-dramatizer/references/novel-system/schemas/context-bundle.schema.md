# ContextBundle Schema

```yaml
context_bundle:
  current_state:
    inline: {}
  recent_chapter_summaries:
    refs: ["summaries/CH009.summary.md", "summaries/CH010.summary.md"]
  relevant_character_states:
    inline: []
  open_loops:
    inline: []
  foreshadows:
    inline: []
  relevant_world_rules:
    refs: ["RULES.md"]
  source_outline:
    refs: ["outlines/arc-02.md"]
  source_scene_draft:
    inline: ""
```

规则：

- 上下文必须命名
- 每个块支持 `inline` 或 `refs`
- 优先给摘要而不是全文
- 尽量只暴露与任务直接相关的块
- 块内允许附加元信息，例如：
  - `digest`
  - `snapshot_ref`
  - `role`
  - `notes`

推荐命名块：

- `current_state`
- `recent_chapter_summaries`
- `relevant_character_states`
- `open_loops`
- `foreshadows`
- `relevant_world_rules`
- `source_outline`
- `source_scene_draft`
