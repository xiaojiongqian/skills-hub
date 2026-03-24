# ChapterSummary Schema

保留“谁做了什么，局面如何改变”的最小记忆。
避免把章节压缩成只剩主题、判断或抽象成长描述。

```yaml
entity_type: "ChapterSummary"
chapter_id: "CHXXX"
one_line: "CHARACTER_A crosses a visible threshold without resolving the larger conflict"
actor_refs:
  - "CHARACTER_A"
  - "COACH_B"
major_beats:
  - "KEY_EVENT_A forces CHARACTER_A into a new setting"
  - "CHARACTER_A secures a temporary gain at visible cost"
state_changes:
  - "CHARACTER_A shifts from hesitation to provisional commitment"
carry_forward:
  - "The next chapter must address the consequences of KEY_EVENT_A"
```
