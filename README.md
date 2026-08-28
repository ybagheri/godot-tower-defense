# Citadel Shield TD

> A production-quality, data-driven Tower Defense game built with **Godot 4**.
> Repository/package identity stays `godot-tower-defense` (branding decision G-09).

---

## Project Status

🚧 Active Development — **Phase 3: Vertical Slice (IN PROGRESS)**

| Phase | State |
|-------|-------|
| 0 — Foundation | ✅ Complete |
| 1 — Engine Foundation | ✅ Complete |
| 2 — Gameplay Prototype | ✅ Complete |
| **3 — Vertical Slice** | 🚧 **In progress** |

Evidence-based snapshot: `docs/00_Project/PROJECT_STATUS.md`.
Phase authority: `docs/00_Project/PROJECT_ROADMAP.md`
(synchronized during the 2026-08-27 repository audit).

---

# Vision

Create a modern, expandable Tower Defense game inspired by classic titles such as Castle TD while remaining completely original in gameplay, architecture and content.

The project is designed around long-term maintainability, modular systems and data-driven gameplay.

---

# Goals

- Professional codebase
- Mobile-first architecture
- Reusable gameplay framework
- Easy content creation
- Clean separation between engine and game content
- AI-friendly project structure
- Commercial quality

---

# Core Principles

- Data Driven
- Component Based
- Godot Native
- Resource Oriented
- Signal Based
- Modular
- Testable
- Scalable

---

# Technology

| Item | Value |
|------|-------|
| Engine | Godot 4.x |
| Language | GDScript 2 |
| Rendering | 2D |
| Platform | Android (Primary) |
| License | MIT |

---

# Repository Structure

```text
godot-tower-defense/
├── project.godot            # version 0.8.0, GL Compatibility renderer
├── icon.svg  LICENSE  README.md  CHANGELOG.md
│
├── assets/                  # raw assets (audio/fonts/icons/music/particles/
│   │                        shaders/sprites/textures/ui)
│   └── sprites/             # SVG art incl. policy-labeled prototype set
│
├── docs/                    # documentation = source of truth (see docs/INDEX.md)
│   ├── INDEX.md
│   ├── 00_Project/          # manifest, roadmap, status report, spec matrix
│   ├── 01_Architecture/     # ARCH-0001 layering & boundaries
│   ├── 04_Specifications/   # SPEC-0001..0016 implementation contracts
│   ├── 05_ADR/              # architecture decision records
│   ├── 12_Game_Design/      # assumptions log + design gap register
│   ├── 10_Testing/          # performance records
│   └── 11_Release/          # REL-0001 Android build guide
│
├── resources/               # data-driven gameplay definitions (.tres)
│   ├── abilities/ enemies/ towers/ stages/ campaigns/
│   ├── balance/ audio/ ui/ localization/
│   └── waves/ settings/     # reserved; wave data is stage-inline today
│
├── scenes/                  # presentation layer
│   ├── game/                # battle.tscn
│   ├── maps/ shared/        # test_range, twin_roads; castle/enemy/tower visuals
│   └── ui/                  # main menu, HUD
│
├── scripts/                 # typed GDScript 2.0
│   ├── core/                # ENGINE layer: entity/component/resource cores
│   ├── managers/            # global services (autoloads)
│   ├── components/ factories/ systems/ resources/ events/
│   ├── gameplay/ utilities/ ui/ debug/
│
├── tests/                   # headless harness; unit/ populated,
│                            # integration/ reserved
└── tools/                   # dev utilities (validators, stress harness, sfx gen)
```

Layering rule (`docs/01_Architecture/ARCHITECTURE_OVERVIEW.md`, ADR-0001):
`scripts/core` is the engine layer and never references game content.
Game systems depend on the engine; the engine never depends on the game.


Layering rule (`docs/01_Architecture/ARCHITECTURE_OVERVIEW.md`, ADR-0001):
`scripts/core` is the engine layer and never references game content.
Game systems depend on the engine; the engine never depends on the game.

---

# Documentation

Documentation lives inside the `/docs` directory.

Every system is designed before implementation.

No production code should be written without an approved specification.

Documentation hierarchy:

```

Project
Architecture
Game Design
Specifications
API
Testing
Release

```

---

# Development Workflow

Idea

↓

Specification

↓

Architecture

↓

Implementation

↓

Testing

↓

Optimization

↓

Release

---

# Architecture

The project follows a hybrid architecture designed specifically for Godot.

Main concepts:

- Scene Based
- Resource Driven
- Component Based
- Event Driven
- Factory Pattern
- Object Pooling

---

# Design Philosophy

The engine does **not** know what a Goblin, Knight or Dragon is.

The engine only understands:

- Entities
- Components
- Systems
- Resources

Game content is built on top of the framework.

---

# Mobile First

The primary target platform is Android.

Every feature must consider:

- Memory usage
- CPU usage
- Battery consumption
- Touch controls
- Mid-range devices

---

# Performance Targets

Target FPS:

60 FPS

Maximum frame time:

16.6 ms

Support:

100+ active enemies

100+ projectiles

without noticeable frame drops on supported hardware.

---

# Coding Standards

- Typed GDScript only
- One responsibility per class
- No hardcoded gameplay values
- No duplicated logic
- Prefer composition over inheritance
- Use Signals where appropriate
- Keep systems modular

---

# Documentation Rules

Every important feature requires:

- Specification
- Architecture documentation
- Acceptance criteria
- Future extension notes

---

# Current Phase

**Phase 3 — Vertical Slice (IN PROGRESS)**

Phases 0–2 complete. Single authoritative source:
`docs/00_Project/PROJECT_ROADMAP.md`; live details:
`docs/00_Project/PROJECT_STATUS.md`.

---

# Roadmap

- Documentation
- Framework
- Prototype
- Vertical Slice
- Alpha
- Beta
- Content Complete
- Polish
- Release Candidate
- Release

---

# Contributing

Contribution guidelines will be available after the architecture reaches version 1.0.

---

# License

MIT License

---

This repository is intended to become a professional, production-quality Tower Defense framework and game built with Godot.
