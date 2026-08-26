# Changelog

All notable changes to the **godot-tower-defense** project are documented here.

## [0.4.0] - 2026-08-26

### Added — Milestone 4: First Playable (Phase 2 complete)

- Bootable game: `scenes/game/battle.tscn` is now the main scene; the full
  §44 loop is playable (start -> prepare -> waves -> build -> fight ->
  upgrade/sell -> castle damage -> victory/defeat -> restart).
- `BattleController` orchestrator wiring all systems; player intents only
  (arm/build/cancel, select, upgrade, sell, pause, 1x/2x speed).
- `BuildingSystem` (SPEC-0007 placement + SPEC-0010 purchases): path
  clearance and tower-spacing validation, payment via wallet, refunds at
  configurable ratio from `BalanceDefinition`.
- `UpgradeComponent` + `TowerUpgradeDefinition` cumulative delta upgrades;
  investment tracking feeds sell refunds.
- `CastleSystem` converts enemy arrivals into castle damage announcements.
- HUD (SPEC-0013): gold / wave+prep countdown / enemies alive / castle bar /
  pause / speed / data-driven build bar from tower catalog / selection panel
  with live stats, upgrade & sell buttons / victory-defeat overlay with
  restart. UI sends intents, never mutates state.
- Localization: `strings.csv` with translation keys for all UI text.
- Content as real `.tres` resources: goblin/wisp/ogre definitions,
  archer tower with 2-step upgrade path, balance resource, and a 5-wave
  stage (`stage.001.test_range`) including a boss wave.
- Prototype placeholder art (clearly labeled SVGs) + cosmetic visual scenes
  referenced by definitions (ASSUMPTION A2).
- Debug tooling start (§28): opt-in `EventProbe` autoload (GTD_EVENT_LOG=1)
  printing lifecycle event counts; inert in production.

### Validated

- 109 unit/integration tests across 17 suites: ALL PASSING (exit 0),
  including battle-scene binding resolution and content validation of all
  shipped `.tres` files.
- Live headless game run (5200 frames, GTD_EVENT_LOG=1): wave starts after
  prep, 6 goblins spawn, all reach castle (6x castle_damaged), wave
  completes, zero script errors.
- validate_scripts: 39 scripts compile clean.

### Fixed

- WaveSystem was never parented under BattleController (masked in M3 tests
  by external staging); battles now actually tick.
- Cross-instance NodePath exports replaced with controller-driven binding
  (ASSUMPTION A8).

## [0.3.0] - 2026-08-26

### Added — Milestone 3: Gameplay Foundation (Phase 2, in progress)

- Definitions, all validated (SPEC-0001): `EnemyDefinition` (stats,
  resistances, rewards, flying/boss flags), `TowerDefinition` (damage,
  speed, range, crit, projectile options, cost, priority),
  `SpawnGroupDefinition` + `WaveDefinition` (SPEC-0005),
  `StageDefinition` (waves, route catalog, prep time, battle start),
  `PathDefinition` waypoints/routes (SPEC-0009).
- Components: `HealthComponent` (death announced once), `StatsComponent`
  runtime stat copies, `LootComponent`, `MovementComponent` waypoint
  follower with speed multiplier and remaining-distance queries,
  `TargetingComponent` (FIRST/CLOSEST/STRONGEST/LOWEST_HEALTH priorities,
  range filter, flying filter), `AttackComponent` (cooldown loop, instant
  or pooled-projectile delivery).
- Systems: `CombatSystem` deterministic damage math + event publication
  (SPEC-0006), pooled chasing `Projectile`, `EnemyRegistry` event-driven
  target tracking, `EnemyEventRelay` translating engine death/arrival into
  game-level enemy events (A5), `WaveSystem` state machine
  (IDLE/PREPARING/SPAWNING/ACTIVE/COMPLETED/FAILED) with merged spawn
  timelines, boss flags, synchronous zero-prep starts for determinism,
  `EconomySystem` wallet (SPEC-0010) and `RewardSystem` kill/wave payouts.
- Factories: `EnemyFactory`, `TowerFactory` assembling configured entities
  from definitions with runtime naming and spawn/built events
  (SPEC-0007/0008).
- Tests: 9 new suites / 50 new tests including a full deterministic
  mini-battle integration (spawn -> path -> kill -> gold -> wave clear ->
  castle arrival -> stage complete/fail). Project total: 91 tests passing.
- `docs/10_Game_Design/ASSUMPTIONS.md` logging inferred design decisions.

### Fixed

- Movement advance no longer requires activation (deterministic testing);
  processing still gated by entity lifecycle.
- Targeting validity based on liveness instead of entity state machine.
- StageDefinition.get_path renamed get_route (collided with Resource API).

### Validated

- import clean; validate_scripts: 29 scripts OK;
  test_runner: ALL SUITES PASSED (exit 0).

## [0.2.0] - 2026-08-26

### Added — Milestone 2: Core Framework (Phase 1, in progress)

- `EventBus` autoload: publish/subscribe event system per SPEC-0004 with
  allocation-free dispatch and safe mid-dispatch unsubscription.
- `GameEvents`: central catalog of event names from SPEC-0004..0015.
- `GameResource` base class (SPEC-0001): id/version/display metadata plus
  error/warning validation contract.
- `ResourceManager` autoload (SPEC-0001 registry): validated registration,
  lookup by id, category queries; gameplay systems never load files directly.
- `GameEntity` (SPEC-0002): component container with lifecycle
  CREATED -> ACTIVE <-> DISABLED -> DESTROYED, scene-child auto-registration,
  programmatic attachment, tags.
- `GameComponent` (SPEC-0003): capability base with setup/activate/deactivate/
  remove hooks and enabled flag.
- `PoolManager` autoload (ARCH-0001 pooling): keyed generic pools with factory
  callables, prewarm, idle caps.
- Headless test harness (`tests/test_runner.tscn`, `TestSuite` base) with zero
  external dependencies; 41 unit tests across 5 suites, all passing.
- `tools/validate_scripts.gd`: compiles every script under `scripts/` headless.

### Validated

- `godot --headless --path . --import` exits clean.
- `godot --headless --path . -s tools/validate_scripts.gd` -> VALIDATION OK.
- `godot --headless --path . res://tests/test_runner.tscn` -> ALL SUITES PASSED (exit 0).

### Fixed

- Removed duplicated second copy of PROJECT_ROADMAP.md content.
- `.gitignore` no longer excludes export_presets.cfg (needed for Android exports).

## [0.1.0] - 2026-08-26

### Added — Milestone 1: Project Bootstrap

- `project.godot` targeting Godot 4.x with GL Compatibility renderer
  (mobile-first), landscape orientation, touch emulation settings.
- MIT LICENSE file (README already claimed MIT).
- Original placeholder `icon.svg` (prototype quality, clearly labeled).
- Audio bus layout: Master / Music / Effects / UI / Ambient / Voice (SPEC-0014).
- Full folder skeleton mandated by ADR-0001; ADR-0001 resolves the
  README-vs-Architecture-vs-owner structure conflict in favor of the owner
  directive while preserving engine/game dependency layering.
- README structure section rewritten to match the implemented layout.
