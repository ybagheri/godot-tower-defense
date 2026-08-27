---
Document ID: PROJ-0005
Title: Project Status Report
Version: 1.0.0
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

- Hero system — listed under Phase 3 but UNSPECIFIED and unimplemented;
  decide via DESIGN_GAPS G-01 before building
- Additional stages beyond stage_001/stage_002 (data-driven; user-requested)
- Integration tests in `tests/integration/` (directory currently EMPTY;
  `battle_integration_test` lives in unit/ today)
- Release signing job (keystore secrets intentionally not configured)

## Known technical debt

| Item | Where noted |
|------|-------------|
| Docs directory numbering collisions (`10_Game_Design` vs `10_Testing`, `11_AI` vs `11_Release`) deviate from INDEX naming rules; renames deferred to avoid breaking cross-references | docs/INDEX.md §Structure |
| ARCH-0001 names an `engine/` layout; the engine layer actually lives at `scripts/core`, `scripts/managers`, … Repo structure is authoritative for existing files | ARCHITECTURE_OVERVIEW follow-up |
| `scripts/components/*` couple to game Definitions (`configure_from_definition(TowerDefinition)` etc.) — pragmatic factory-wiring deviation from strict layering; documented, core itself stays pure | This report |
| Prototype SVG art placeholders (assets/sprites policy paths) | Art status below |
| Historical doc/test count drift: CHANGELOG-era "156 tests"; suite sums to 157 since 2026-08-27 harness fix era | CHANGELOG forward-corrected |

## Known design assumptions

Tracked in `docs/10_Game_Design/ASSUMPTIONS.md` (A1–A11); prioritized
resolution list in `docs/10_Game_Design/DESIGN_GAPS.md`.

## Test status

**24 suites / 157 tests — ALL PASSING** headless (Godot 4.7.2, 2026-08-27),
plus validate_scripts.gd (55 scripts compile OK) and the CI stress smoke gate.

## CI status

GitHub Actions two-job pipeline proven green through run #16: `test`
(import → compile-check → tests → stress smoke gating on `RESULT avg_frame`)
then `android-debug-apk`. Pin 4.7.2-stable matches project.godot. Push
71765a3 awaits its run result.

## Android status

- Debug APK PROVEN GREEN (CI run #16, attempt #1, ~28 MB artifact).
- Presets: GL Compatibility, ETC2/ASTC, sensor landscape (project setting 4),
  touch emulation both directions.
- Device install/touch/save/audio verification PENDING (M10).
- Export preset version/name was stale 0.6.0 vs project 0.8.0 — aligned
  2026-08-27 during this audit.

## Art status

Placeholder SVGs for all enemies/towers/castle; dark medieval theme applied
(0.7.0). Reduced-FX accessibility toggle shipped. No final art yet.

## Current blockers

1. M10 human gate needs a physical Android device round per artifact.
2. DESIGN_GAPS P0 decisions before further gameplay content work.

## Next milestone

M11 — Vertical Slice completion candidate: resolve GAPS P0, add the
requested new stages as data-only content if P0 allows, verify end-to-end
on device, and apply the branding decision (G-09).

## Definition of Done — next milestone

- All DESIGN_GAPS P0 entries RESOLVED with recorded decisions.
- ≥3 playable stages chained in campaign; unlocks persist across app
  restart (round-trip backed by progression test additions).
- Zero known touch-input defects; REL-0001 checklist rows for touch, save
  path and audio ticked on at least one mid-range device.
- On-device 60 FPS profile recorded in PERFORMANCE.md (replacing the NOT
  VERIFIED marker), within the 16.6 ms budget.
- CI green with expanded suites; docs synchronized in the same commits.

