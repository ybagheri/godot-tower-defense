---
Document ID: ADR-0002
Title: Repository Layout Is Authoritative for the Engine Layer
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-08-27
Last Updated: 2026-08-27
Dependencies:
  - ARCH-0001 Architecture Overview
  - ADR-0001 Repository Structure
---

# ADR-0002: Repository Layout Is Authoritative for the Engine Layer

## Status
Approved (2026-08-27)

## Context

ARCH-0001 predates implementation and describes an aspirational top-level
`engine/` directory. The implemented repository instead carries the engine
capability across:

```
scripts/core        GameEntity / GameComponent / GameResource primitives
scripts/managers    autoload services (EventBus, ResourceManager,
                    PoolManager, AudioManager, SaveManager, SceneManager)
scripts/events      GameEvents catalog of typed StringName events
```

AUDIT-2026-08-27 verified `scripts/core` itself contains zero references to
game concepts (grep over enemies/towers/stages/campaign/gold: clean), so the
GAME -> ENGINE -> GODOT dependency rule holds IN BEHAVIOR.

Two naming-level tensions were audited:

1. The layer lives under differently-named folders than the doc claims.
2. `scripts/components/*` declare typed configuration hooks over game
   Definition resources (`configure_from_definition(TowerDefinition)`,
   `apply_enemy_definition(...)`, LootComponent gold/castle fields).
   Components are assembled exclusively by factories, which keeps creation
   single-sourced (assumption A2 lineage).

## Decision

1. MIGRATE THE DOCUMENT, NOT THE CODE. Renaming/moving stable, tested
   modules to match prose would churn every import and break CI history for
   zero behavioral gain. ARCH-0001 is amended to describe the real mapping;
   future architecture docs MUST reference `scripts/...` paths directly.

2. LAYER RULES (binding):
   - `scripts/core`: NEVER references game Definitions, systems, factories,
     managers or event constants beyond entity lifecycle primitives.
     Verified by grep audit each time it is touched.
   - `scripts/events/GameEvents` is the shared vocabulary registry; StringName
     constants alone do not create behavioral coupling, but event NAMES for
     game entities must keep flowing through relays (A5) - core components
     publish ENTITY_* events only.
   - `scripts/components`: MAY type against Definition resources from
     `scripts/resources` for passive configuration data ONLY (no behavior
     imports, no manager access beyond EventBus announcements already in
     place). This deviation is ACCEPTED and documented here; tightening to
     strict isolation was rejected as ceremony without payoff for a
     factory-assembled component model.
   - Factories remain the sole creation point for runtime entities.

## Consequences

- CI grep guard can later enforce rule 2 mechanically (P2 candidate).
- New contributors read ARCH-0001 for BOUNDARIES and this ADR for PATHS.
- If the engine is ever extracted for reuse, extraction starts at
  scripts/core + managers/events per this mapping.
