# Design Gaps Register

Unresolved design decisions derived from the repository audit (2026-08-27).
Companion to `ASSUMPTIONS.md`: assumptions keep implementations honest;
this register decides when and what replaces them. Every entry blocks or
shapes upcoming work — nothing here may silently harden into architecture.

Priorities:

- **P0** — must decide before further implementation work
- **P1** — needed before Vertical Slice completion
- **P2** — decidable during polish

| # | Pri | Topic | Open question | Why it matters now |
|---|-----|-------|---------------|--------------------|
| G-01 | P0 | Heroes | Is the hero system IN the Vertical Slice at all? PROJ-0002 lists it; zero spec/code exists | Blocks honest VS scope and any roadmap re-planning; cheapest correct answer may be deferral to Phase 4 |
| G-02 | P0 | Damage model | Ratify assumption A1's formula/numbers (armor chip-min, % resistance, TRUE, crit multiplier) as the FINAL rule | New enemy/tower content multiplies against it; changing later invalidates existing .tres tuning |
| G-03 | P0 | Tower roster | Final VS tower set beyond archer/mage/cannon (count, roles, upgrade identity)? | Requested "more stages" assume a stable offering bar |
| G-04 | P0 | Enemy roster | Which enemies define the VS difficulty ladder? wisp-fast/knight-elite exist; is ogre-boss the only boss? Flying mix ratio? | Stage authoring and balancing depend on it; flying flag defaults are provisional (A3) |
| G-05 | P1 | Status effects | Ordering: slow-as-debuff-now vs waiting for full StatusEffect component (A10) | Freeze-only combat may feel thin in longer stages; affects ability roster too |
| G-06 | P1 | Progression | Star thresholds (70%/35%) and unlock policy ratified? Cost curves for economy pacing? | Unlock persistence already ships; wrong thresholds invalidate saves later |
| G-07 | P1 | Stage structure | VS stage count target (roadmap example says 5; repo has 2), map variety rules, wave-count norms | Defines the actual deliverable set for Phase 3 closure |
| G-08 | P1 | Castle behavior | Any repair/regen/active abilities vs current passive HP pool? Damage-to-castle on breach per-enemy (LootComponent) confirmed? | Small feature, big balance leverage |
| G-09 | P1 | Branding | Apply final branding **Citadel Shield TD**: project.godot config/name, Android package display name, README title, in-game menu title | Store-visible identity; mechanical once decided (repo name stays godot-tower-defense) |
| G-10 | P2 | Abilities | Meteor/Frost tuning + cast-delay feel across device latency | Polish-phase data change only |
| G-11 | P2 | Audio | Replace synthesized SFX/music with commissioned audio; move event→sound table to data when designers retune (A11) | Pure swap behind AudioManager catalog seam |
| G-12 | P2 | Art | Replace prototype SVGs with authored art bible output | Theme system already isolates colors/fonts |
| G-13 | P2 | Tooling | Path-drawing editor tool so maps never desync waypoints↔Line2D visuals again (A7) | Level-design velocity once stage count grows |

Decision protocol: resolving a gap updates this row to RESOLVED (<date>,
decision), moves any permanent rule into 03_GameBible category content or the
relevant SPEC, and flips affected ASSUMPTIONS entries to superseded.
