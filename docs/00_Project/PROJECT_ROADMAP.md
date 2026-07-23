---
Document ID: PROJ-0002
Title: Project Roadmap
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - ARCH-0001 Architecture Overview
Related ADR:
  - None
Related RFC:
  - None
---

# Project Roadmap

## Purpose

This document defines the development phases of the **godot-tower-defense** project.

The roadmap describes:

- development order
- phase goals
- expected outputs
- completion criteria

The roadmap prevents premature implementation and architecture instability.

---

# Development Philosophy

The project follows this order:

```
Documentation

↓

Architecture

↓

Core Framework

↓

Prototype

↓

Vertical Slice

↓

Content Production

↓

Polish

↓

Release
```

---

# Phase 0 — Foundation

Status:

```
IN PROGRESS
```

## Goal

Create the project foundation.

---

## Tasks

- Repository structure
- Documentation system
- Architecture definition
- Coding standards
- AI development context

---

## Deliverables

```
README.md

docs/

.ai/

Project Rules
```

---

## Completion Criteria

✓ Repository structure exists

✓ Architecture is documented

✓ Development rules are defined

✓ Future systems have clear specifications

---

# Phase 1 — Engine Foundation

Status:

```
PLANNED
```

## Goal

Create the reusable gameplay framework.

---

## Systems

### Resource System

Responsible for:

- definitions
- data loading
- validation


### Entity System

Responsible for:

- runtime objects
- entity lifecycle


### Component System

Responsible for:

- reusable capabilities


### Event System

Responsible for:

- communication between systems

---

## Deliverables

```
engine/

core/

entity/

components/

resources/

systems/
```

---

## Completion Criteria

✓ Entity can be created

✓ Components can be attached

✓ Resources can define content

✓ Systems can process entities

---

# Phase 2 — Gameplay Prototype

Status:

```
PLANNED
```

## Goal

Create a minimum playable version.

---

## Prototype Content

One complete battle:

- one map
- one castle
- one tower
- one enemy
- one wave
- one reward system

---

## Purpose

Validate:

- architecture
- gameplay loop
- performance

---

## Completion Criteria

Player can:

✓ Start a level

✓ Place a tower

✓ Fight enemies

✓ Win or lose

✓ Receive rewards

---

# Phase 3 — Vertical Slice

Status:

```
PLANNED
```

## Goal

Create a small but polished version of the final game.

---

## Content

Example:

- 5 stages
- multiple towers
- multiple enemies
- hero system
- abilities
- progression

---

## Focus

Quality over quantity.

---

## Completion Criteria

The game should represent the final product experience.

---

# Phase 4 — Core Content Production

Status:

```
PLANNED
```

## Goal

Expand the game content.

---

## Add:

- campaign stages
- enemies
- bosses
- towers
- heroes
- upgrades
- skills

---

## Important Rule

New content should require mostly:

- Resources
- Scenes
- Configuration

and minimal engine changes.

---

# Phase 5 — Meta Systems

Status:

```
PLANNED
```

## Systems

- progression
- economy
- achievements
- unlocks
- settings
- save system

---

# Phase 6 — Polish

Status:

```
PLANNED
```

## Focus

- animations
- effects
- audio
- UI improvement
- optimization

---

# Phase 7 — Release Preparation

Status:

```
PLANNED
```

## Tasks

- Android testing
- performance profiling
- device compatibility
- store preparation
- release builds

---

# Phase 8 — Post Release

Status:

```
FUTURE
```

Possible additions:

- new campaigns
- events
- expansions
- additional game modes

---

# Feature Development Rule

Every new feature follows this pipeline:

```
Idea

↓

Design Document

↓

Specification

↓

Architecture Review

↓

Implementation

↓

Testing

↓

Documentation Update
```

---

# Priority System

Features are prioritized by:

## P0 — Critical

Required for game functionality.

Examples:

- combat
- enemies
- towers

---

## P1 — Important

Required for complete product.

Examples:

- progression
- save system
- UI systems

---

## P2 — Enhancement

Improves quality.

Examples:

- effects
- accessibility
- extra modes

---

# Current Focus

Current project phase:

```
Phase 0 — Foundation
```

Next milestone:

```
Complete Architecture Documentation
```

---

# Long Term Goal

Create a stable, reusable Tower Defense framework where future games can be built with minimal engine changes.

---

# End of Document---
Document ID: PROJ-0002
Title: Project Roadmap
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - ARCH-0001 Architecture Overview
Related ADR:
  - None
Related RFC:
  - None
---

# Project Roadmap

## Purpose

This document defines the development phases of the **godot-tower-defense** project.

The roadmap describes:

- development order
- phase goals
- expected outputs
- completion criteria

The roadmap prevents premature implementation and architecture instability.

---

# Development Philosophy

The project follows this order:

```
Documentation

↓

Architecture

↓

Core Framework

↓

Prototype

↓

Vertical Slice

↓

Content Production

↓

Polish

↓

Release
```

---

# Phase 0 — Foundation

Status:

```
IN PROGRESS
```

## Goal

Create the project foundation.

---

## Tasks

- Repository structure
- Documentation system
- Architecture definition
- Coding standards
- AI development context

---

## Deliverables

```
README.md

docs/

.ai/

Project Rules
```

---

## Completion Criteria

✓ Repository structure exists

✓ Architecture is documented

✓ Development rules are defined

✓ Future systems have clear specifications

---

# Phase 1 — Engine Foundation

Status:

```
PLANNED
```

## Goal

Create the reusable gameplay framework.

---

## Systems

### Resource System

Responsible for:

- definitions
- data loading
- validation


### Entity System

Responsible for:

- runtime objects
- entity lifecycle


### Component System

Responsible for:

- reusable capabilities


### Event System

Responsible for:

- communication between systems

---

## Deliverables

```
engine/

core/

entity/

components/

resources/

systems/
```

---

## Completion Criteria

✓ Entity can be created

✓ Components can be attached

✓ Resources can define content

✓ Systems can process entities

---

# Phase 2 — Gameplay Prototype

Status:

```
PLANNED
```

## Goal

Create a minimum playable version.

---

## Prototype Content

One complete battle:

- one map
- one castle
- one tower
- one enemy
- one wave
- one reward system

---

## Purpose

Validate:

- architecture
- gameplay loop
- performance

---

## Completion Criteria

Player can:

✓ Start a level

✓ Place a tower

✓ Fight enemies

✓ Win or lose

✓ Receive rewards

---

# Phase 3 — Vertical Slice

Status:

```
PLANNED
```

## Goal

Create a small but polished version of the final game.

---

## Content

Example:

- 5 stages
- multiple towers
- multiple enemies
- hero system
- abilities
- progression

---

## Focus

Quality over quantity.

---

## Completion Criteria

The game should represent the final product experience.

---

# Phase 4 — Core Content Production

Status:

```
PLANNED
```

## Goal

Expand the game content.

---

## Add:

- campaign stages
- enemies
- bosses
- towers
- heroes
- upgrades
- skills

---

## Important Rule

New content should require mostly:

- Resources
- Scenes
- Configuration

and minimal engine changes.

---

# Phase 5 — Meta Systems

Status:

```
PLANNED
```

## Systems

- progression
- economy
- achievements
- unlocks
- settings
- save system

---

# Phase 6 — Polish

Status:

```
PLANNED
```

## Focus

- animations
- effects
- audio
- UI improvement
- optimization

---

# Phase 7 — Release Preparation

Status:

```
PLANNED
```

## Tasks

- Android testing
- performance profiling
- device compatibility
- store preparation
- release builds

---

# Phase 8 — Post Release

Status:

```
FUTURE
```

Possible additions:

- new campaigns
- events
- expansions
- additional game modes

---

# Feature Development Rule

Every new feature follows this pipeline:

```
Idea

↓

Design Document

↓

Specification

↓

Architecture Review

↓

Implementation

↓

Testing

↓

Documentation Update
```

---

# Priority System

Features are prioritized by:

## P0 — Critical

Required for game functionality.

Examples:

- combat
- enemies
- towers

---

## P1 — Important

Required for complete product.

Examples:

- progression
- save system
- UI systems

---

## P2 — Enhancement

Improves quality.

Examples:

- effects
- accessibility
- extra modes

---

# Current Focus

Current project phase:

```
Phase 0 — Foundation
```

Next milestone:

```
Complete Architecture Documentation
```

---

# Long Term Goal

Create a stable, reusable Tower Defense framework where future games can be built with minimal engine changes.

---

# End of Document
