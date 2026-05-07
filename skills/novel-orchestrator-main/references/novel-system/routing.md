# Routing

## Role Pack Matrix

Use these role packs inside `novel-orchestrator-main`; they are not separate skills.

- `canon_keeper`
  - Maintain canon, character state, timeline, current state, open loops, foreshadows, arc state, and minimal writeback patches.
- `plot_planner`
  - Plan master outline, arc, chapter promise, scene beats, reveal order, repair plans, and sequel entry points.
- `scene_writer`
  - Draft or revise a scene/chapter from approved beats; turn facts into events, actions, choices, costs, reactions, and residue.
- `voice_editor`
  - Revise dialogue, subtext, character voice, interaction pressure, and protagonist embodiment without changing plot facts.
- `continuity_gate`
  - Audit canon, timeline, knowledge boundaries, causality, language surface, and writeback eligibility.
- `memory_summarizer`
  - Compress stable chapters into summaries, recent events, state patches, carry-forward obligations, and tension residue.

## Dispatch Sizing

Default unit:

- Full audit: `1 chapter`
- Planning: `1 chapter`, `1 arc segment`, or `1 repair cluster`
- Draft/revision: `1 chapter` or `1 dominant scene chain`
- Dialogue pass: `1 dialogue scene` or the dialogue-bearing parts of `1 chapter`
- Summary: stable text, usually `1 to 2 chapters`
- State update: one coherent change set

For large ranges such as `CH001-CH010`, triage first, then split only the failing chapters or clusters.

## Standard Chapter Workflow

1. Read `INDEX.md` and `CURRENT_STATE.md`.
2. Load relevant open loops, arcs, summaries, and canon.
3. Set `chapter_promise`.
4. Run `plot_planner` for scene-ready beats when structure is not already stable.
5. Run `scene_writer` for a draft or targeted revision.
6. Run `voice_editor` only when character embodiment or dialogue pressure is weak.
7. Run `quality_council_loop` when the user asks for publishable/high-quality output.
8. Run `memory_summarizer` after the text is stable.
9. Run `canon_keeper` for conservative writebacks.

## Serial Continuation Workflow

Use this when starting a sequel, extending beyond the planned outline, or continuing an indefinite series:

1. `continuation_handshake`
   - Summarize stable ending state, unresolved obligations, relationship debts, active unknowns, and usable seeds.
2. `horizon split`
   - `now`: current scene/chapter pressure.
   - `near`: obligations for the next 1 to 3 chapters.
   - `far`: seeds that can sleep without forcing an early payoff.
3. `candidate discipline`
   - Mark uncertain future ideas as `candidate`, `seed`, `active_unknown`, or `recommendation`.
   - Do not write them into canon until confirmed by text or user.
4. `episode entry`
   - Give the new installment its own disturbance and core event.
   - Inherit consequences, not homework lists.
5. `state refresh`
   - After a stable chapter, update summaries and state with only confirmed facts.

## Serial vs Parallel

Default to serial for generation chains:

1. Plan
2. Draft
3. Audit
4. Repair
5. Summarize
6. Write back

Parallelize only when tasks share the same stable input snapshot and cannot contaminate one another, such as independent council seats reviewing the same draft.

## Standard Task Types

- Planning: `master-outline`, `arc-plan`, `chapter-plan`, `scene-beats`, `reveal-plan`, `continuation-plan`
- Generation: `scene-draft`, `chapter-draft`, `dialogue-pass`, `prose-revision`
- Audit: `continuity-audit`, `quality-council`, `character-consistency-audit`, `timeline-audit`, `dialogue-audit`
- Memory: `chapter-summary`, `recent-events`, `current-state-sync`, `open-loop-update`, `foreshadow-update`
- Canon: `story-bible-update`, `character-entry`, `world-rule-entry`, `timeline-entry`, `arc-state-entry`

## Timeout Recovery

1. Wait once.
2. If it times out, shrink scope and tighten output format.
3. Retry once.
4. If it still fails, fallback only for light analysis, summary, or targeted revision.
5. Timeout fallback cannot be the sole basis for canon writeback.
