# Design Gaps Register

Unresolved design decisions derived from the repository audit (2026-08-27).
P0/P1 resolutions were made 2026-08-27 by ratified design documents
(02_GDD/*, SPEC-0006/0011 notes, ADR-0002/0003); each row records its
decision. Assumption flips are annotated inside `ASSUMPTIONS.md` itself.

Priorities:

- **P0** — must decide before further implementation work
- **P1** — needed before Vertical Slice completion
- **P2** — decidable during polish

| # | State | Decision (2026-08-27) |
|---|-------|------------------------|
| G-01 | **RESOLVED** | Hero system DEFERRED to Phase 4: zero spec/code exists and shipping heroes would force spec+art+balance trio under deadline pressure with no VS-loop payoff. PROJ-0002 updated accordingly; Phase 4 carries an explicit spec-first restart requirement. |
| G-02 | **RESOLVED** | Damage model RATIFIED FINAL exactly as A1 specified; frozen verbatim into SPEC-0006 Ratification Note. Future changes require a new ADR plus .tres migration. | 
| G-03 | **RESOLVED** | VS tower bar FROZEN at three towers (Archer/Arcane Spire/Bombard) with roles and upgrade fantasies fixed in 02_GDD/TOWERS.md; control-tower candidates await StatusEffect system (Phase 4). |
| G-04 | **RESOLVED** | Enemy ladder FROZEN at four enemies in 02_GDD/ENEMIES.md: goblin filler, wisp flyer, knight wall, Ogre Warlord as the SINGLE boss of every finale. Flying mix norm: >=20% non-boss spawns from stage 3 onward. Difficulty scales via counts/timing only inside stages. |
| G-05 | **RESOLVED** | Scope locked: VS ships FREEZE-only; slow/burn/chain StatusEffect family is a Phase 4 milestone (A10 superseded into a decision). |
| G-06 | **RESOLVED** | Policy ratified into SPEC-0011 Ratification Note: star thresholds moved OUT OF CODE into balance_default.tres (BalanceDefinition fields, defaults preserve 0.7/0.35 so saves stay valid); sequential >=1-star unlock retained. Regression-tested incl. custom-balance band. |
| G-07 | **RESOLVED** | Stage plan ratified in 02_GDD/STAGES.md AND SHIPPED: five stages (Test Range, Twin Roads, Ironwood Pass, Broken Crossroads, Warlords Gate), map archetypes varied, wave norms fixed (8 waves normal, <=10 cap, single boss wave, shrinking prep). |
| G-08 | **RESOLVED** | Castle model for VS: passive HP pool + per-enemy breach damage (LootComponent.damage_to_castle), no regen/repair acts. Any active-defense mechanic is a Phase 4 idea, not a promise. |
| G-09 | **RESOLVED** | Branding **Citadel Shield TD** applied: project.godot config/name, Android package display names, README title/H1, main-menu title label. Git repo/package id godot-tower-defense intentionally untouched. |
| G-10 | P2 | OPEN - Meteor/Frost tuning awaits device-latency feel data. |
| G-11 | P2 | OPEN - Commissioned audio replaces synthesized SFX behind AudioManager catalog; event->sound table moves to data when designers retune (A11). Blocked on external assets; nothing fabricated. |
| G-12 | P2 | OPEN - Authored art replaces prototype SVGs behind theme system seams. Blocked on external assets; prototype set untouched meanwhile. |
| G-13 | P2 | OPEN-SPEC - Path-drawing editor tool remains specced-in-principle via STAGES.md authoring rule (Line2D==waypoints manual until tool exists); implementation is a candidate for a dedicated RFC. |


Decision protocol: resolving a gap updates this row to RESOLVED (<date>,
decision), moves any permanent rule into 03_GameBible category content or the
relevant SPEC, and flips affected ASSUMPTIONS entries to superseded.
