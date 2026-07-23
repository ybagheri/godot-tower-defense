---
Document ID: DOC-0000
Title: Documentation Index
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Last Updated: 2026-07-23
---

# Documentation Index

This document is the entry point for the entire documentation of the **godot-tower-defense** project.

Every document inside this repository belongs to one of the categories listed below.

---

# Documentation Philosophy

The documentation is considered part of the source code.

No production feature should exist without documentation.

Every important system must have:

- Architecture
- Specification
- Acceptance Criteria
- Future Extension Notes

---

# Directory Structure

```
docs/

├── INDEX.md
│
├── 00_Project/
│
├── 01_Architecture/
│
├── 02_GDD/
│
├── 03_GameBible/
│
├── 04_Specifications/
│
├── 05_API/
│
├── 06_Balance/
│
├── 07_ArtBible/
│
├── 08_AudioBible/
│
├── 09_UIBible/
│
├── 10_Testing/
│
├── 11_Release/
│
├── 12_ADR/
│
└── 13_RFC/
```

---

# 00_Project

Project level documentation.

Files

```
PROJECT_MANIFEST.md

PROJECT_ROADMAP.md

CHANGELOG.md

GLOSSARY.md

STYLE_GUIDE.md
```

Purpose

Project vision and long-term direction.

---

# 01_Architecture

High-level engine architecture.

Files

```
ARCHITECTURE_OVERVIEW.md

ENGINE_LAYER.md

ENTITY_MODEL.md

RESOURCE_MODEL.md

EVENT_SYSTEM.md

SAVE_SYSTEM.md
```

Purpose

Describe how the engine is built.

---

# 02_GDD

Game Design Document.

Files

```
GAME_VISION.md

GAMEPLAY_LOOP.md

TOWERS.md

ENEMIES.md

HEROES.md

SPELLS.md

STAGES.md

CAMPAIGN.md
```

Purpose

Describe gameplay.

---

# 03_GameBible

Permanent design rules.

Examples

```
DESIGN_PRINCIPLES.md

GAME_RULES.md

NAMING.md

ECONOMY_RULES.md

PROGRESSION_RULES.md

```

Purpose

Defines rules that should rarely change.

---

# 04_Specifications

The most important documentation.

Every gameplay system has one specification.

Examples

```
SPEC-0001-RESOURCE-SYSTEM.md

SPEC-0002-ENTITY-SYSTEM.md

SPEC-0003-COMPONENT-SYSTEM.md

SPEC-0004-EVENT-BUS.md

SPEC-0005-WAVE-SYSTEM.md

SPEC-0006-COMBAT.md

SPEC-0007-TOWER-SYSTEM.md

SPEC-0008-HERO-SYSTEM.md

SPEC-0009-AI.md

SPEC-0010-SAVE.md
```

Purpose

Implementation contracts.

---

# 05_API

Public interfaces.

Examples

```
RESOURCE_API.md

EVENT_API.md

SAVE_API.md
```

Purpose

Stable interfaces between systems.

---

# 06_Balance

Gameplay balancing.

Examples

```
ENEMY_STATS.md

TOWER_STATS.md

HERO_STATS.md

ECONOMY.md

XP_CURVES.md
```

Purpose

Gameplay numbers.

---

# 07_ArtBible

Visual identity.

Examples

```
STYLE.md

CHARACTERS.md

ENVIRONMENTS.md

ANIMATION.md

VFX.md

ICONS.md
```

Purpose

Visual consistency.

---

# 08_AudioBible

Music and sound.

Examples

```
MUSIC.md

SFX.md

VOICE.md
```

---

# 09_UIBible

User Interface.

Examples

```
HUD.md

MAIN_MENU.md

SHOP.md

SETTINGS.md

COLORS.md
```

---

# 10_Testing

Testing documentation.

Examples

```
TEST_PLAN.md

UNIT_TESTS.md

PERFORMANCE.md

BUG_PROCESS.md
```

---

# 11_Release

Release process.

Examples

```
ANDROID.md

GOOGLE_PLAY.md

VERSIONING.md

POST_RELEASE.md
```

---

# 12_ADR

Architecture Decision Records.

Naming

```
ADR-0001-....

ADR-0002-....

ADR-0003-....
```

Purpose

Record architectural decisions.

ADR documents are immutable.

---

# 13_RFC

Request For Comments.

Naming

```
RFC-0001-....

RFC-0002-....

RFC-0003-....
```

Purpose

Discuss future changes before implementation.

RFCs may become ADRs.

---

# Document Lifecycle

```
Draft

↓

Review

↓

Approved

↓

Implemented

↓

Archived
```

---

# Document Header Standard

Every document begins with:

```yaml
---
Document ID:
Title:
Version:
Status:
Owner:
Created:
Last Updated:
Dependencies:
Related ADR:
Related RFC:
---
```

---

# Naming Rules

Folders

PascalCase

Examples

```
GameBible

Specifications

Architecture
```

Files

UPPER_SNAKE_CASE is **not** used.

Use:

```
PROJECT_MANIFEST.md

ENGINE_LAYER.md

SPEC-0001-RESOURCE-SYSTEM.md
```

---

# Versioning

Documentation follows Semantic Versioning.

Examples

```
1.0.0

1.1.0

2.0.0
```

---

# Approval Process

Every major document must be:

Draft

↓

Reviewed

↓

Approved

before implementation begins.

---

# Documentation Rule

The documentation is the single source of truth.

If implementation and documentation differ,

**the documentation must be updated first.**

---

# End of Document---
