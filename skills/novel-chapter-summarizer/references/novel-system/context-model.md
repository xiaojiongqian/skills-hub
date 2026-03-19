# Context Model

## Progressive Disclosure

上下文采用四层加载：

1. 项目入口层
   - `INDEX.md`、`CURRENT_STATE.md`
2. 相关状态层
   - `OPEN_LOOPS.md`、`CHARACTER_ARCS.md`、`RECENT_EVENTS.md`、`ARC_STATUS.md`
3. 静态设定层
   - `WORLD.md`、`CHARACTERS.md`、`FACTIONS.md`、`LOCATIONS.md`、`RULES.md`、`THEMES.md`、`STYLE_GUIDE.md`
4. 正文与局部原文层
   - 当前章节、相邻章节、场景草稿、相关章节摘要

只有必要时才向下展开。

## Summary First

优先提供：

- 当前状态摘要
- 章节摘要
- 角色动态摘要
- 开放回路条目
- 伏笔条目
- 时间线条目

尽量不要直接堆全文。

## Named Context Bundles

不要把上下文拼成一大段。
应按命名块组织：

- `current_state`
- `recent_chapter_summaries`
- `relevant_character_states`
- `open_loops`
- `foreshadows`
- `relevant_world_rules`
- `source_outline`
- `source_scene_draft`

命名上下文能让主 skill 更容易裁剪、替换和追踪来源。
