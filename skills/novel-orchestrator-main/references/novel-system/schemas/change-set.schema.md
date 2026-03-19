# ChangeSet Schema

```yaml
change_set:
  summary: "Advance Lin's distrust arc and close harbor-key loop"
  changes:
    - operation: "update"
      target_file: "CHARACTER_ARCS.md"
      entity_type: "CharacterState"
      entity_id: "char-lin"
      before_summary: "Distrusts Shen but still follows him"
      after_summary: "Chooses tactical cooperation while planning a betrayal"
      rationale: "Shown in CH012 confrontation"
      evidence_refs: ["chapters/CH012.md"]
      related_targets: ["CURRENT_STATE.md"]
```

`operation` 推荐值：

- `add`
- `update`
- `resolve`
- `remove`
