---
Document ID: PROJ-0006
Title: Specification Implementation Matrix
Version: 1.0.0
Status: Approved
Owner: Engineering
Created: 2026-08-27
Last Updated: 2026-08-28
Dependencies:
  - PROJ-0005 Project Status Report
  - SPEC-0001..0016 Specifications
---

# Specification Implementation Matrix

Status values: IMPLEMENTED · PARTIAL · NOT IMPLEMENTED · UNKNOWN.
"Evidence" cites repository artifacts verified by inspection, not file
existence alone. Behavior claims are backed by named tests executed in the
headless runner (25 suites / 161 tests ALL PASSING, 2026-08-28).

| Specification | Status | Evidence | Tests | Notes |
|---|---|---|---|---|
| SPEC-0001 Resource System | IMPLEMENTED | ResourceManager register/has/get by id; GameResource.validate() error chain; all gameplay data as .tres under resources/ | resource_manager_test (8), definitions_test (8), content_validation_test (5) | Content validation runs over every shipped definition |
| SPEC-0002 Entity System | IMPLEMENTED | GameEntity tags/components/lifecycle; factory-generated ids/names | game_entity_test (9), factory_test | Entities pooled-safe (reset patterns tested) |
| SPEC-0003 Component System | IMPLEMENTED | GameComponent activation/deactivation/removal contract; Health, Movement, Targeting, Attack, Stats, Loot, Upgrade components | health_component_test (6), movement_component_test (6), targeting_component_test (6), attack_component_test (4), factory_test | Components couple to game Definitions for configuration — recorded deviation, not violation of runtime behavior |
| SPEC-0004 Event System | IMPLEMENTED | EventBus subscribe/unsubscribe/publish/clear typed StringName events in GameEvents; engine-pure ENTITY_* vs game ENEMY_* split via EnemyEventRelay (assumption A5) | event_bus_test (9) | Listener ordering deterministic; clear() used between tests |
| SPEC-0005 Wave System | IMPLEMENTED | WaveSystem.start(stage)/fail_stage; wave data embedded as WaveDefinition sub-resources inside stage .tres (verified stage_001: 5 waves) | battle_integration_test (6), wave completion covered in lifecycle_progression_test | resources/waves/ empty dir reserved; data locality is stage-inline by design |
| SPEC-0006 Combat System | IMPLEMENTED | CombatSystem + pooled Projectile; DamageTypes physical-flat-armor(min chip)/elemental-percent-resist/TRUE; crit post-mitigation (assumption A1 formula) | combat_system_test (8) | Formula values await Combat GDD ratification (DESIGN_GAPS G-02) |
| SPEC-0007 Tower System | IMPLEMENTED | TowerFactory assembly; BuildingSystem check_placement reasons gold/path-clearance/spacing; upgrades + sell refunds | building_system_test (7), factory_test | can_target_flying default true until roster counter-play decided (A3) |
| SPEC-0008 Enemy System | IMPLEMENTED | EnemyFactory tag/component assembly incl. flying/boss flags; visual_scene cosmetic root (A2) | factory_test (5) | Spawn-on-first-waypoint fix regression-tested 2026-08-27 |
| SPEC-0009 Path System | IMPLEMENTED | PathDefinition validate/first_waypoint/destination/total_length; MovementComponent waypoint advance + arrival event; routes externalized to resources/paths/*.tres with route_id metas binding map Line2Ds (SPEC-0016) | movement_component_test (6), factory regressions, content_validation_test (7) | Manual Line2D sync debt (A7) closed by validated route_id contract |
| SPEC-0010 Economy System | IMPLEMENTED | EconomySystem can_afford/spend; RewardSystem gold on death; purchase failure surfaces as notification toast | economy_test (6), building_system_test | Balance numbers exclusively in balance_default.tres (A4) |
| SPEC-0011 Progression System | IMPLEMENTED (v1) | ProgressionTracker stars=max(stars, f(castle_ratio)) persisted via SaveManager; CampaignDefinition stage unlocking | campaign_system_test (7), lifecycle_progression_test (5) | Unlock curve/star thresholds need design pass (G-06) |
| SPEC-0012 Save System | IMPLEMENTED | Versioned JSON with migration hook, corrupt-file quarantine, future-version rejection | save_manager_test (5) | No rewrite needed; defect-free as directed |
| SPEC-0013 UI System | PARTIAL | HUD bind-last pattern (A8); build/upgrade/sell/pause/speed; result overlay; main menu + campaign select; localized strings; placement-failure toasts (2026-08-27) | polish_systems_test (8), reduced_fx_test (4) | Desktop-verified; FULL ON-DEVICE flow pending M10; settings surface limited to reduced-FX toggle |
| SPEC-0014 Audio System | IMPLEMENTED (v1) | AudioManager catalogs + event→sound const table (A11); music battle track; synthesized SFX assets committed | audio_manager_test (6) | Provenance = repo synthesis tool (A9); device output unverified |
| SPEC-0015 Ability System | PARTIAL (intentional v1) | AbilitySystem arm/cooldown/spend/cast-delay; AREA_DAMAGE explosion + FREEZE freeze live (ability_meteor_strike.tres, ability_frost_grasp.tres) | ability_system_test (6) | Burn/slow/chain deferred behind StatusEffect milestone (A10) — do not mark done early |

## Systems without dedicated specifications

| Area | Status | Note |
|---|---|---|
| Hero system | NOT IMPLEMENTED / UNSPECIFIED | Listed in PROJ-0002 Phase 3 content; no SPEC exists — resolve before any implementation (G-01) |
| Localization pipeline | IMPLEMENTED (en only) | CSV→translation import; single locale |
