# Changelog

All notable changes to the **godot-tower-defense** project are documented here.

## [Unreleased]

### Fixed

- CI/Android: write editor settings under the filename Godot actually
  loads (`editor_settings-<major>.<minor>.tres`; the previous full-version
  name made Godot ignore the Java/SDK paths entirely), fail the export
  step loudly on non-zero exit or missing APK instead of failing silently
  at artifact upload, remove a duplicated upload step, scope diagnostics
  to `export_log.txt`, and clean up only `assets/android` after template
  chunk extraction so game assets survive into the packaged PCK.
- CI/Android: install Android export templates under the directory name
  Godot actually resolves — `export_templates/<major>.<minor>.<patch>.<status>`
  dot-separated (e.g. `4.7.2.stable`) — instead of the release-tag hyphen
  form (`4.7.2-stable`), which the engine never matches, making every
  export abort instantly with "No export template found". The install
  step now also asserts both reassembled template APKs are non-empty and
  logs the resolved directory into the job summary.
- CI/Android: harden the runner-side export against intermittent silent
  kills during Godot's first filesystem scan — persistent `.godot`
  import cache, 3-attempt retry loop with verbose logging on retries,
  preflight assertions over every exporter input, and public annotation
  telemetry (`::notice` inputs, `A<n>_EXP[k]` engine-log lines) so red
  runs stay diagnosable without authenticated artifact access. Inputs
  themselves were verified end-to-end by an identical local reproduction
  producing a signed debug APK.

## [0.8.0] - 2026-08-26

### Added — Milestone 9: Android Optimization groundwork

- Performance stress harness (`tools/stress_battle.tscn`, parameterized)
  and measured baseline (`docs/10_Testing/PERF_BASELINE.md`): gameplay
  logic <0.1 ms/frame up to 500 enemies + 30 towers; ~6.9 ms headless
  floor dominates. Micro-optimizations deferred until device profiles
  demand them (measure-first discipline).
- Reduced-FX accessibility setting (§49): pause-menu checkbox persisted in
  SaveManager settings; gates floating text entirely and disables screen
  shake live (battery + motion sensitivity).
- Projectile pool prewarm (8) to avoid mid-battle instantiation spikes.
- `run/max_fps=60` project setting for high-refresh-device battery.

### Evidence & honesty notes

- Android export templates ship as one 1.28 GB tpz (verified via HTTP
  header) - too large for this sandbox; selective android-only extraction
  documented in REL-0001 as the constrained-machine path. APK remains
  NOT VERIFIED pending templates/JDK/SDK on real hardware.

### Validation

Tests 156 / 24 suites ALL PASSING (reduced-FX gating across VFX+shake,
settings round-trip, prewarm-adjusted pool expectations). validate_scripts
55 OK; stress harness runs clean at three load tiers.

## [0.7.0] - 2026-08-26

### Added — Milestone 8: Polish & Juice

- Dark medieval UI theme resource (`theme_dark_medieval.tres`): stone
  panels with aged-gold borders, themed buttons (normal/hover/pressed/
  disabled), progress bars; applied to main menu and battle HUD.
- Screen shake: trauma-based `CameraShake` camera reacting to castle
  damage and impactful meteor hits (squared falloff, clamped, settles).
- Boss health bar: HUD top-center panel appears while a living boss is on
  the field, driven by `EnemyRegistry.get_boss()` and the entity's health.
- Attack feedback: small muzzle bursts on every tower attack start.
- Result overlay gained a Main Menu transition button (SceneManager).
- Performance instrumentation (§28): EventProbe now prints periodic FPS +
  worst-frame-time when GTD_EVENT_LOG=1.

### Baseline measured (headless CI sandbox)

~145 fps sustained logic rate; worst frame settles ~7 ms after the
expected first-window startup spike (143 ms includes engine warmup).

### Validation

143 -> 151 tests / 23 suites ALL PASSING (shake math/bounds/settling,
event-driven shake gating, boss lookup incl. dead-boss filtering, theme
wiring across menu+HUD). validate_scripts 55 OK; live smoke zero errors.

## [0.6.0] - 2026-08-26

### Added — Milestone 6: Slice Polish + Android Groundwork

- Floating combat text: pooled rising numbers for damage (crits marked),
  "+gold" popups on kills; event-driven via BattleVfx with a 24-floater
  screen cap and pool recycling.
- Placement preview: ghost tower visual follows the pointer while armed,
  with live attack-range circle tinted green/red by BuildingSystem validity.
- Pause menu: resume/restart plus Master/Music/Effects volume sliders,
  persisted through SaveManager settings section (SPEC-0049/0012) and
  applied to audio buses on startup.
- Music transitions: battle drone stops on victory/defeat so result stings
  read cleanly.
- Android groundwork: validated export_presets.cfg (Debug + Release,
  arm64-v8a, immersive landscape, ETC2/ASTC project setting) and
  docs/11_Release/ANDROID.md with exact maintainer setup steps.
- exports/ added to .gitignore.

### Validation status

- 136 tests / 21 suites ALL PASSING (new: battle VFX pooling/cap/retire,
  music transitions, placement checks through the wired battle scene).
- validate_scripts 50 OK; import clean; live headless smoke run zero
  script errors.
- **Android APK build NOT VERIFIED** (honest): sandbox lacks export
  templates, JDK 17 and the Android SDK. Preset parsing verified via
  headless Godot error surface; remaining steps documented in REL-0001.

## [0.5.0] - 2026-08-26

### Added — Milestone 5: Vertical Slice content & systems (Phase 3, in progress)

- **Ability system** (SPEC-0015 v1): `AbilityDefinition` +
  `AbilitySystem` with arm->tap-cast flow, gold costs, per-ability
  cooldowns, deterministic `advance()` timing; two shipped abilities:
  Meteor Strike (delayed AoE fire damage) and Winter's Grasp (freeze).
- **Audio** (SPEC-0014): `AudioManager` autoload with event->sound mapping,
  voice cap (10), per-sound throttling, music looping on the Music bus;
  `AudioDefinition` resources; 8 SFX + battle drone loop synthesized by
  `tools/generate_sfx.gd` (project-generated provenance, ASSUMPTION A9).
- **Save** (SPEC-0012 v1): `SaveManager` autoload - versioned JSON at
  user://save/save_001.json, section store/load, corrupt-file quarantine,
  future-version rejection, migration hook; `ProgressionTracker` records
  best star rating per stage (>=70% -> 3 stars per SPEC-0011); victory
  overlay shows stars.
- **New towers**: Arcane Spire (magic damage bypasses armor) and Bombard
  (high damage, ground-only, crits) - added purely as data + visuals,
  zero core-code changes (scalability proof per §46).
- **Elite enemy**: Fallen Knight (armored, magic-resistant) woven into
  waves 3-5; stage now fields 4 enemy types incl. boss.
- **VFX**: pooled expanding-ring bursts for deaths, gate arrivals, meteor
  explosion and frost pulse (`BattleVfx`, `BurstEffect`).
- HUD ability bar with live cooldown text and ready state.

### Fixed

- **M4 regression**: dead/goal-reached enemies were never removed from the
  tree. New `EnemyLifecycleSystem` deactivates + fades deaths and despawns
  arrivals; out-of-tree entities free immediately.
- Programmatic components no longer flagged duplicate when their entity
  later enters the tree.
- HUD binds after all systems are wired (ability bar built from live
  catalog); dictionary lookups defensive.

### Validated

- 130 tests / 20 suites ALL PASSING (ability, audio, save, lifecycle,
  progression, extended content validation).
- validate_scripts: 48 scripts clean; import clean.
- Live headless run (9000 frames): 2 waves started, 16 enemies spawned
  across goblin/wisp/knight types, wave completed, castle damaged 11x,
  ZERO script errors.

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
