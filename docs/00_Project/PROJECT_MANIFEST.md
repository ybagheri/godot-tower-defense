---
Document ID: PROJ-0001
Title: Project Manifest
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies: None
Related ADR: None
Related RFC: None
---

# Project Manifest

## Purpose

This document defines the identity, philosophy, long-term vision and non-negotiable engineering principles of the **godot-tower-defense** project.

It is the highest-level document in the repository.

Every architectural decision, gameplay system and implementation must comply with this document.

---

# Mission

Create a professional-quality 2D Tower Defense game and reusable gameplay framework using Godot 4.

The framework must support long-term development, clean architecture and efficient content creation without requiring frequent engine modifications.

---

# Vision

The project aims to become a modern Tower Defense framework where:

- gameplay systems are modular
- content is data-driven
- documentation is considered part of the source code
- new gameplay content can be added with minimal programming

The first game built on the framework will be an original experience inspired by classic mobile Tower Defense games while introducing its own mechanics, balance and visual identity.

---

# Primary Objectives

1. Create a maintainable codebase.
2. Support long-term feature expansion.
3. Separate engine systems from game content.
4. Prioritize performance on Android devices.
5. Make development friendly for both humans and AI assistants.
6. Produce documentation suitable for commercial development.

---

# Project Scope

The repository contains two logical layers.

## Engine Layer

Reusable gameplay framework.

Responsibilities:

- entity management
- component management
- combat systems
- event systems
- save/load
- object pooling
- reusable gameplay utilities

The engine contains no game-specific knowledge.

---

## Game Layer

Contains all gameplay content.

Examples:

- enemies
- towers
- heroes
- stages
- waves
- campaign
- user interface
- audio configuration

The game layer depends on the engine.

The engine never depends on the game.

---

# Design Philosophy

The following principles are permanent.

## 1. Godot Native

The framework extends Godot.

It does not replace it.

Godot features should be preferred whenever they provide a clean solution.

Examples:

- Scenes
- Resources
- Signals
- AnimationPlayer
- TileMap
- Navigation

---

## 2. Data Driven

Gameplay content should be described using Resources.

Examples include:

- enemy definitions
- tower definitions
- stage definitions
- wave definitions
- hero definitions

Programming should rarely be required to create new content.

---

## 3. Modular

Each gameplay system must have a clearly defined responsibility.

Large classes with unrelated responsibilities are prohibited.

---

## 4. Mobile First

The primary deployment platform is Android.

All technical decisions must consider:

- CPU usage
- RAM usage
- battery consumption
- startup time
- loading time

Desktop support is considered a secondary target.

---

## 5. Performance Matters

Optimization is part of the design process.

Performance should not rely on late-stage fixes.

Systems expected to create many objects must support pooling where appropriate.

---

## 6. Documentation First

Every significant feature begins with documentation.

Implementation starts only after the specification has been reviewed.

---

## 7. Maintainability

The project is expected to remain maintainable for many years.

Readable code is preferred over clever code.

---

# Non-Goals

The following are intentionally outside the initial project scope.

- Multiplayer
- PvP
- Online services
- Live events
- Cloud saves
- Procedural map generation

These may be introduced in future versions after the core framework reaches maturity.

---

# Repository Rules

The following rules are mandatory.

## Rule 1

No hardcoded gameplay values.

Gameplay values belong in configuration resources.

---

## Rule 2

No duplicated gameplay logic.

Shared behavior must be extracted into reusable systems or components.

---

## Rule 3

No undocumented gameplay features.

Every significant mechanic requires documentation.

---

## Rule 4

No architecture changes without an ADR.

Major architectural decisions must be recorded before implementation.

---

## Rule 5

Documentation is part of the product.

Updating documentation is required whenever implementation changes.

---

# Documentation Hierarchy

The following order defines project authority.

1. Project Manifest
2. Architecture Documents
3. Specifications
4. Game Design Documents
5. Implementation

If two documents conflict, the higher document has priority.

---

# Quality Standards

The framework should achieve the following characteristics.

- predictable
- modular
- testable
- scalable
- documented
- reusable
- readable
- maintainable

---

# Success Criteria

The project will be considered successful when:

- new enemies can be added without engine modification
- new towers can be be created primarily through Resources
- gameplay systems remain independent
- documentation stays synchronized with implementation
- the project runs smoothly on supported Android devices

---

# Guiding Principle

The engine should understand gameplay systems.

It should never understand game lore.

Enemies, heroes, kingdoms and stories belong to the game layer.

---

# Project Motto

Design carefully.

Implement confidently.

Maintain continuously.

---

# End of Document
