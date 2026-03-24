# ChangeSet Schema

```yaml
change_set:
  summary: "Advance CHARACTER_A's state and update downstream project memory"
  changes:
    - operation: "update"
      target_file: "CHARACTER_ARCS.md"
      entity_type: "CharacterState"
      entity_id: "char-a"
      before_summary: "Hesitates at the current threshold"
      after_summary: "Commits to a provisional next step under pressure"
      rationale: "Shown in CHXXX turning point"
      evidence_refs: ["chapters/CHXXX.md"]
      related_targets: ["CURRENT_STATE.md"]
```

`operation` 推荐值：

- `add`
- `update`
- `resolve`
- `remove`

兼容说明：

- legacy workflow 中，`change_set` 也可能是数组
- 新 contract 推荐统一过渡到对象形态，便于附加 summary、evidence 和 related_targets
