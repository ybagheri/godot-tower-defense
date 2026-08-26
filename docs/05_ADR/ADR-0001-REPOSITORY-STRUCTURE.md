---
Document ID: ADR-0001
Title: Repository Structure Resolution
Version: 1.0.0
Status: Accepted
Owner: Project Architecture
Created: 2026-08-26
Last Updated: 2026-08-26
Dependencies:
  - PROJ-0001 Project Manifest
  - ARCH-0001 Architecture Overview
Related ADR: None
Related RFC: None
---

# ADR-0001: Repository Structure Resolution

## Status

Accepted (2026-08-26, delegated by project owner for implementation).

## Context

Three competing physical layouts exist in project sources:

1. `README.md` proposes `src/autoload|components|entities|systems|ui|levels|resources|utils`.
2. `docs/01_Architecture/ARCHITECTURE_OVERVIEW.md` places the engine layer in `engine/core|entity|components|systems|resources|services|utilities`.
3. The owner's master development instruction mandates `scripts/`, `scenes/`, `resources/`, `assets/`, `tests/`, `tools/`.

All three describe the same logical architecture; they differ only in physical mapping.

## Decision

Adopt the **owner-directed layout**:

```
scripts/   core | managers | systems | entities | components | factories
           resources | events | gameplay | ui | utilities | debug
scenes/    game | ui | towers | enemies | projectiles | effects | maps | shared
resources/ abilities | enemies | towers | waves | stages | balance
           localization | settings
assets/    audio | fonts | icons | materials | music | particles | shaders
           sprites | textures | ui
tests/     unit | integration
tools/
```

The Engine/Game dependency rule from ARCH-0001 is preserved semantically:

- `scripts/core/`, `scripts/events/`, `scripts/factories/` (generic parts), and base classes under
  `scripts/resources/` form the **engine layer**.
- Engine-layer code must not reference game content (no Goblin/Dragon/Tower-specific types).
- Game layer (`scripts/systems/`, `scripts/gameplay/`, `scripts/entities/`, `scripts/ui/`,
  `scripts/managers/`, content resources) depends on the engine layer, never the reverse.

## Consequences

- `README.md` structure section will be updated to match reality (English only).
- ARCHITECTURE_OVERVIEW's `engine/` path reference is superseded by this ADR;
  the document remains authoritative for layering rules.
- Future folder additions require justification but not a new ADR unless they change layering.

## End of Document
