---
Document ID: PROJ-0005
Title: Project Status Report
Version: 1.1.0
Status: Approved
Owner: Project Architecture
Created: 2026-08-27
Last Updated: 2026-08-27
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0002 Project Roadmap
---

# Project Status Report

Single authoritative source for "where the project actually is". Evidence-
based; every claim points at repository artifacts. Updated whenever a phase,
milestone or system changes state.

## Current phase

**Phase 3 — Vertical Slice: IN PROGRESS**

(Per PROJ-0002. Phases 0/1/2 COMPLETE — evidence below.)

## Completed phases

| Phase | Evidence |
|-------|----------|
| 0 Foundation | Repository layout, docs system (INDEX + 13 categories), ADR-0001, SPEC-0001..0015 all Approved, CI green |
| 1 Engine Foundation | `scripts/core` (GameEntity/GameComponent/GameResource), six manager autoloads, event bus, resource validation — unit-tested |
| 2 Gameplay Prototype | Full battle loop playable and testable: waves from PathDefinition routes, towers place/attack/upgrade/sell, economy pays/rewards, victory/defeat decide, save persists (`battle_integration_test`, `lifecycle_progression_test`) |

## Current milestone

**M10 — Android device verification**: device touch/install testing is the
final human gate per REL-0001. M9 groundwork shipped in 0.8.0.

## Completed systems

| System | Key code | Tests |
|--------|----------|-------|
| Resource system | ResourceManager, GameResource.validate() chain | resource_manager_test (8), content_validation_test (5) |
| Entity/component core | GameEntity, GameComponent lifecycle | game_entity_test (9), game_resource_test (8) |
| Events | EventBus + GameEvents registry | event_bus_test (9) |
| Combat | CombatSystem, pooled Projectile, DamageTypes | combat_system_test (8), attack_component_test (4) |
| Towers | TowerFactory, BuildingSystem, UpgradeComponent | building_system_test (7), factory_test (5), targeting_component_test (6) |
| Enemies | EnemyFactory, EnemyRegistry, EnemyLifecycleSystem | factory_test, lifecycle_progression_test (5) |
| Paths/movement | PathDefinition, MovementComponent | movement_component_test (6) |
| Economy | EconomySystem wallet, RewardSystem | economy_test (6) |
| Waves | WaveSystem over stage-embedded wave data | battle_integration_test (6) |
| Progression | ProgressionTracker stars, campaign unlock gating | campaign_system_test (7) |
| Save | SaveManager versioning/quarantine/migration hook | save_manager_test (5) |
| UI | HUD/menu/campaign select; touch fixes 2026-08-27 | polish_systems_test (8), reduced_fx_test (4) |
| Audio v1 | AudioManager + synthesized SFX | audio_manager_test (6) |
| Abilities v1 | AREA_DAMAGE + FREEZE archetypes | ability_system_test (6) |

## Partially implemented systems

| System | Done | Missing |
|--------|------|---------|
| Abilities (SPEC-0015) | 2 archetypes live | Status-effect family (slow/burn/chain) intentionally deferred (A10) |
| UI (SPEC-0013) | Complete on desktop; touch placement/movement defects fixed 2026-08-27 | On-device full-flow pass pending (M10 gate); settings limited to reduced-FX |
| Audio (SPEC-0014) | Synthesized SFX + music bus, event mapping | Device output verification; data-driven retune deferred |

## Planned systems / content

- Hero system DEFERRED to Phase 4 by decision G-01 (spec-first restart required).
- Release signing: scaffolded DORMANT CI job awaiting maintainer secrets
  (see REL-0001 manual prerequisite); nothing fabricated in its place.
- Phase 4 candidates: StatusEffect family, control tower, castle acts.
- All five VS stages SHIPPED as of this version (G-07); content polish and
  tuning continue against device data.

## Known technical debt

| Item | Where noted |
|------|-------------|
| Historical CHANGELOG lines keep pre-rename doc paths (log semantics); live refs migrated per ADR-0003 | ADR-0003 |
| Prototype SVG art placeholders (assets/sprites policy paths) | Art status below |
| Historical doc/test count drift: CHANGELOG-era "156 tests"; suite sums to 157 since 2026-08-27 harness fix era | CHANGELOG forward-corrected |

## Known design assumptions

Tracked in `docs/12_Game_Design/ASSUMPTIONS.md` (A1–A11); resolution
register at `docs/12_Game_Design/DESIGN_GAPS.md`.

## Test status

**24 suites / 159 tests — ALL PASSING** headless (Godot 4.7.2, 2026-08-27),
plus validate_scripts.gd (55 scripts compile OK) and the CI stress smoke gate.
Taxonomy now matches intent: unit suites run first, the battle integration
suite runs from `tests/integration/`. New regressions cover data-driven
star thresholds and the five-stage campaign chain.

## CI status

Three-job pipeline: `test` → `android-debug-apk` proven green (run #16);
a third `android-release-apk` job exists but is DORMANT behind the
RELEASE_SIGNING_ENABLED repository variable until the maintainer supplies
keystore secrets (REL-0001 §Release signing). Pin 4.7.2-stable matches
project.godot.

## Android status

- Debug APK PROVEN GREEN (CI run #16, attempt #1, ~28 MB artifact).
- Presets: GL Compatibility, ETC2/ASTC, sensor landscape (project setting 4),
  touch emulation both directions.
- Device install/touch/save/audio verification PENDING (M10 human gate).
- Package display name now ships the ratified brand (G-09); package id
  io.github.ybagheri.godottd unchanged for store continuity.

## Art status

Placeholder SVGs for all enemies/towers/castle; dark medieval theme applied
(0.7.0). Reduced-FX accessibility toggle shipped. No final art yet.

## Current blockers

1. M10 human gate: one physical mid-range device round (touch, save path,
   audio, on-device FPS) to close REL-0001 checklist items.

## Next milestone

M11 — close the M10 device checklist and tune from real play data:
adjust wave pacing only through .tres if needed, record on-device FPS into
PERFORMANCE.md, then judge VS complete. P2 gaps (abilities feel, audio, art,
tool RFC) proceed afterwards as asset/tool work arrives.

## Definition of Done — next milestone

- All DESIGN_GAPS P0 entries RESOLVED with recorded decisions.
- ≥3 playable stages chained in campaign; unlocks persist across app
  restart (round-trip backed by progression test additions).
- Zero known touch-input defects; REL-0001 checklist rows for touch, save
  path and audio ticked on at least one mid-range device.
- On-device 60 FPS profile recorded in PERFORMANCE.md (replacing the NOT
  VERIFIED marker), within the 16.6 ms budget.
- CI green with expanded suites; docs synchronized in the same commits.

