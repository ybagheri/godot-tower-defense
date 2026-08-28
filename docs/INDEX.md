---
Document ID: DOC-0000
Title: Documentation Index
Version: 1.1.0
Status: Approved
Owner: Project Architecture
Created: 2026-07-23
Last Updated: 2026-08-27
---

# Documentation Index

This document is the entry point for the entire documentation of the **godot-tower-defense** project.

Every document inside this repository belongs to one of the categories listed below.

> **v1.1.0 (audit sync, 2026-08-27):** this revision synchronizes the index
> with the ACTUAL repository contents. The repository structure is
> authoritative for what exists; categories or files that are planned but do
> not exist yet are explicitly marked **PLANNED** instead of being listed as
> if present. Folder-numbering collisions between existing directories are
> recorded as known debt (see below) rather than silently renamed.

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

# Directory Structure (actual)

```
docs/
├── INDEX.md                 # this file (DOC-0000)
├── 00_Project/              # project-level documents
├── 01_Architecture/         # high-level architecture
├── 02_GDD/                  # VS scope ratifications (towers/enemies/stages)
├── 04_Specifications/       # SPEC-0001..0016 contracts
├── 05_ADR/                  # architecture decision records
├── 06_Art/                  # art bible                   [EMPTY — PLANNED]
├── 07_Lore/                 # world lore                  [EMPTY — PLANNED]
├── 08_Audio/                # audio bible                 [EMPTY — PLANNED]
├── 09_Level_Design/         # level design                [EMPTY — PLANNED]
├── 10_Testing/              # testing documentation
├── 11_Release/              # release process
└── 12_Game_Design/          # design assumptions & gaps
```

There is no `03_GameBible/`, `05_API/`, `06_Balance/`, `07_ArtBible/`,
`08_AudioBible/`, `09_UIBible/`, `12_ADR/` or `13_RFC/`. The v1.0.0 index
listed aspirational names that were never created. ADRs live in `05_ADR/`;
a home for RFCs stays PLANNED until the first RFC exists.

**Numbering:** canonicalized 2026-08-27 via ADR-0003 — collisions resolved
(`10_Game_Design` renamed to **`12_Game_Design`**; empty untracked `11_AI`
placeholder removed). Number **03** stays reserved for the future GameBible.
Never reuse numbers without an RFC/ADR.

---

# 00_Project — Project level documentation

Files (actual):

```
PROJECT_MANIFEST.md             # PROJ-0001 vision & rules
PROJECT_ROADMAP.md              # PROJ-0002 phases — authoritative statuses
PROJECT_STATUS.md               # PROJ-0005 evidence-based status snapshot
SPEC_IMPLEMENTATION_MATRIX.md   # PROJ-0006 spec vs implementation map
GLOSSARY.md                     # PROJ-0003 terms
STYLE_GUIDE.md                  # PROJ-0004 conventions
```

Note: the project CHANGELOG lives at the **repository root**
(`CHANGELOG.md`), not inside docs/.

Purpose: project vision, phases and long-term direction.

---

# 01_Architecture

Files (actual):

```
ARCHITECTURE_OVERVIEW.md   # ARCH-0001 layers, boundaries, layering rule
```

PLANNED: ENGINE_LAYER / ENTITY_MODEL / RESOURCE_MODEL / EVENT_SYSTEM /
SAVE_SYSTEM deep-dives — create on demand, not speculatively.

Purpose: describe how the engine is built. Layering rule:
GAME → ENGINE → GODOT; the engine must never depend on game-specific
content.

---

# 02_GDD — Game Design Document

Files (actual):

```
TOWERS.md   # VS tower bar ratified (G-03)
ENEMIES.md  # VS ladder, flying-mix and boss rules ratified (G-04)
STAGES.md   # 5-stage plan, map archetypes, wave norms (G-07)
```

PLANNED: GAME_VISION / GAMEPLAY_LOOP / SPELLS / CAMPAIGN deep-dives.
Until authored, ability scope lives in ASSUMPTIONS (A10) and campaign
structure in campaigns/*.tres plus these three documents.

---

# 04_Specifications

Files (actual):

```
SPEC-0001 RESOURCE    SPEC-0006 COMBAT      SPEC-0011 PROGRESSION
SPEC-0002 ENTITY      SPEC-0007 TOWER       SPEC-0012 SAVE
SPEC-0003 COMPONENT   SPEC-0008 ENEMY       SPEC-0013 UI
SPEC-0004 EVENT       SPEC-0009 PATH        SPEC-0014 AUDIO
SPEC-0005 WAVE        SPEC-0010 ECONOMY     SPEC-0015 ABILITY
SPEC-0016 PATH-CATALOG
```

All Approved. Implementation state per contract: see
`00_Project/SPEC_IMPLEMENTATION_MATRIX.md`.

Purpose: implementation contracts. No production code without one.

---

# 05_ADR

Files (actual):

```
ADR-0001-REPOSITORY-STRUCTURE.md
ADR-0002-REPOSITORY-LAYOUT-AUTHORITATIVE.md
ADR-0003-DOCS-NUMBERING-CANONICALIZED.md
```

ADRs are immutable once approved; superseding requires a new ADR.

---

# 06_Art                                   [EMPTY — PLANNED]
# 07_Lore                                  [EMPTY — PLANNED]
# 08_Audio                                 [EMPTY — PLANNED]
# 09_Level_Design                          [EMPTY — PLANNED]

Reserved categories; create documents when content work begins. Current art
state: prototype SVGs under assets/sprites (policy-labeled placeholders).
Current audio state: synthesized SFX from tools/generate_sfx.gd.

---

# 12_Game_Design

Files (actual):

```
ASSUMPTIONS.md   # A1-A11 pre-GDD assumptions with revisit triggers
DESIGN_GAPS.md   # G-01.. unresolved decisions, prioritized P0/P1/P2
```

Purpose: keep inferred design honest until real design documents land.

---

# 10_Testing

Files (actual):

```
PERF_BASELINE.md   # PERF-0001 initial logic baseline (2026-08-26)
PERFORMANCE.md     # PERF-0002 measured performance record
```

PLANNED: TEST_PLAN / UNIT_TESTS catalog / BUG_PROCESS.

Harness reality: the headless runner discovers `tests/unit/*_test.gd` first,
then `tests/integration/*_test.gd` (battle suite lives there since 2026-08-27).

---

# 11_Release

Files (actual):

```
ANDROID.md   # REL-0001 Android build guide, CI status, checklist
```

PLANNED: GOOGLE_PLAY / VERSIONING / POST_RELEASE when store work starts.

---

# 11_AI                                    [EMPTY — PLANNED]

Placeholder folder from early setup; intended AI-development context notes.
Treat as unused until populated.

---

# Document Lifecycle

Draft → Review → Approved → Implemented → Archived

---

# Document Header Standard

Every document begins with a YAML front-matter block carrying at minimum:
Document ID, Title, Version, Status, Owner, Created, Last Updated.

---

# Naming Rules

Folders use numbered prefixes per the structure above. Document IDs follow
the `XXX-NNNN` registry (DOC, PROJ, ARCH, SPEC, ADR, REL, PERF) zero-padded;
next free PROJ id: PROJ-0007.

---

# Versioning

Documentation follows Semantic Versioning (`1.0.0`, `1.1.0`, …).

---

# Approval Process

Every major document must pass Draft → Reviewed → Approved before
implementation begins.

---

# Documentation Rule

The documentation is the single source of truth.

If implementation and documentation differ,

**the documentation must be updated first.**

---

# End of Document
