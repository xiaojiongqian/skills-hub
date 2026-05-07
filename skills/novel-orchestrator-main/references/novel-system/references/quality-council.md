# Quality Council

`quality_council_loop` is the high-quality chapter loop inside `novel-orchestrator-main`.

It prevents two common failures:

- The drafting role becomes too generous toward its own text.
- A single reviewer mixes structure, scene heat, voice, continuity, and surface language into one vague opinion.

## Minimum Complete Unit

Run one bounded loop:

1. Produce a reviewable draft.
2. Send independent council seats the same stable snapshot.
3. Aggregate failed dimensions.
4. Repair only the smallest failed cluster.
5. Re-audit the affected dimensions plus counterforce checks.

## Seat Ownership

- `story_engine_seat`
  - role pack: `plot_planner`
  - owns: `opening_hook`, `core_event`, `escalation`
- `scene_heat_seat`
  - role pack: `scene_writer`
  - owns: `scene_execution`, `ending_hook`
- `voice_embodiment_seat`
  - role pack: `voice_editor`
  - owns: `character_embodiment`
- `canon_surface_gate`
  - role pack: `continuity_gate`
  - owns: `continuity_causality`, `language_surface`
  - veto: hard canon conflict, evidence insufficiency, writeback ineligibility

Non-owner seats may leave advisory comments, but only owner seats set canonical scores.

## Blind Audit

First-round scoring defaults to blind audit:

- Each seat receives an independent `seat_context_snapshot`.
- Seats do not see same-round peer findings.
- Seats do not see same-round peer scorecards.
- Seats do not use author self-justification as evidence.

The orchestrator aggregates only after seats return.

## Pass Rule

Pass when all are true:

- `score_total >= 72/80`
- No `blockers`
- No canonical dimension below `7/10`
- `canon_surface_gate` has no veto

## Ratchet Rule

- Dimensions scored `>= 8/10` with no blocker become `locked_dimensions`.
- Repair owners must respect locked dimensions.
- Reopen a locked dimension only when there is concrete regression evidence.

## Repair Routing

Map the failed root cause to the smallest owner:

- Structure root cause: `plot_planner`
- Scene heat, bridge leak, cold ending: `scene_writer`
- Character embodiment, dialogue pressure, subtext: `voice_editor`
- Language surface:
  - default `scene_writer`
  - use `voice_editor` if concentrated in dialogue
- Canon, timeline, state conflict: `canon_keeper`, then `continuity_gate` verifies

Each round should use at most `2` repair owners.

## Counterforce Protocol

Do not accept owner self-report as proof.

- `plot_planner` repair
  - counterforce: `scene_heat_seat`
  - check that stronger structure did not make the scene cold.
- `scene_writer` repair
  - counterforce: `story_engine_seat`
  - check that hotter prose did not empty the plot turn.
- `voice_editor` repair
  - counterforce: `scene_heat_seat`
  - check that better lines still land as pressure and action.
- `canon_keeper` repair
  - counterforce: `story_engine_seat`
  - check that cleaner canon did not flatten chapter propulsion.

`canon_surface_gate` always keeps final veto.

## Convergence Guard

Stop when:

- Pass rule is met.
- Three rounds have run.
- Total gain is below `3/80`.
- No failed dimension rises by at least `1`.
- The same blocker repeats for two rounds.
- Repair begins to damage locked dimensions or cause broad structure drift.
