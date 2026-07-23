---
Document ID: PROJ-0003
Title: Project Glossary
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

# Project Glossary

## Purpose

This document defines the official terminology used throughout the **godot-tower-defense** project.

The purpose is to prevent ambiguity between:

- developers
- designers
- documentation
- AI assistants
- future contributors

All project documents should use these definitions.

---

# Core Architecture Terms

---

# Engine

## Definition

The reusable technical framework responsible for providing gameplay infrastructure.

The Engine contains no knowledge about specific game content.

Examples:

The Engine knows:

- Entity
- Component
- System
- Resource

The Engine does not know:

- Goblin
- Dragon
- Knight
- Kingdom

---

# Game

## Definition

The specific product built using the Engine.

The Game contains:

- characters
- enemies
- towers
- stages
- campaigns
- visual identity

---

# Entity

## Definition

A runtime object that exists during gameplay.

An Entity is created from a definition and receives components.

Examples:

- Enemy
- Tower
- Hero
- Projectile

An Entity itself should contain minimal logic.

---

Example:

```
Goblin Entity

+
Health Component

+
Movement Component

+
Attack Component

+
AI Component
```

---

# Component

## Definition

A reusable unit that provides a specific capability or stores a specific state.

Components are attached to Entities.

---

Examples:

```
HealthComponent

MovementComponent

AttackComponent

TargetComponent

InventoryComponent
```

---

## Component Responsibility

A Component:

- owns state
- exposes data
- emits events when necessary

A Component does not:

- control the entire game
- manage unrelated systems

---

# System

## Definition

A gameplay processor responsible for executing logic.

Systems operate on Entities and Components.

---

Examples:

```
CombatSystem

MovementSystem

AISystem

WaveSystem

RewardSystem
```

---

# Resource

## Definition

A Godot Resource used to store design-time data.

Resources describe what something is.

They do not represent active runtime objects.

---

Examples:

```
EnemyDefinition

TowerDefinition

StageDefinition
```

---

# Definition

## Definition

A Resource that describes the configuration of a gameplay object.

Examples:

```
GoblinDefinition

ArrowTowerDefinition

Stage001Definition
```

---

# Runtime

## Definition

The active state of the game while running.

Examples:

```
Goblin Instance

Active Tower

Current Wave
```

---

# Scene

## Definition

A Godot scene file representing a reusable runtime object or environment.

Examples:

```
enemy.tscn

tower.tscn

stage.tscn
```

---

# Instance

## Definition

A runtime copy created from a Scene or Resource.

Example:

```
Goblin.tscn

        |

        v

Goblin Instance
```

---

# Factory

## Definition

A system responsible for creating runtime objects.

Factories separate creation logic from gameplay logic.

---

Example:

```
EnemyDefinition

        |

        v

EnemyFactory

        |

        v

Enemy Instance
```

---

# Manager

## Definition

A service responsible for coordinating a global system.

Managers should be limited and focused.

---

Good examples:

```
AudioManager

SaveManager

SceneManager
```

---

Bad examples:

```
GameManager

EverythingManager
```

---

# Service

## Definition

A reusable non-gameplay utility providing functionality.

Examples:

```
SaveService

AudioService

LocalizationService
```

---

# Event

## Definition

A message describing that something happened.

Events allow systems to communicate without direct dependency.

---

Example:

```
EnemyDiedEvent

TowerUpgradedEvent

WaveCompletedEvent
```

---

# Signal

## Definition

Godot's built-in event communication mechanism.

Signals are preferred for communication between Nodes.

---

# Pipeline

## Definition

A sequence of processing stages.

Example:

```
Resource

↓

Factory

↓

Entity

↓

Systems

↓

Events
```

---

# Gameplay Terms

---

# Tower

## Definition

A defensive structure that attacks enemies.

A Tower is created from a TowerDefinition.

---

# Enemy

## Definition

A hostile Entity attempting to reach or damage the player's objective.

Enemies are defined by EnemyDefinition resources.

---

# Hero

## Definition

A special controllable or semi-controlled powerful Entity with unique abilities.

---

# Wave

## Definition

A timed sequence of enemy spawning events.

Example:

```
Wave 1

Goblin x10

Wave 2

Goblin x15

Orc x5
```

---

# Stage

## Definition

A complete playable level.

A Stage contains:

- map
- objectives
- waves
- rewards
- difficulty settings

---

# Campaign

## Definition

A collection of ordered stages forming a progression path.

---

# Ability

## Definition

A gameplay action that can be activated or triggered.

Examples:

- Fireball
- Heal
- Freeze

---

# Status Effect

## Definition

A temporary gameplay modification.

Examples:

```
Burn

Freeze

Poison

Slow
```

---

# Upgrade

## Definition

A permanent improvement applied to a gameplay object.

Examples:

```
Tower Damage Upgrade

Hero Skill Upgrade
```

---

# Economy Terms

---

# Resource Currency

## Definition

Any collectible value used for progression.

Examples:

```
Gold

Crystals

Experience
```

---

# Reward

## Definition

A value granted after completing an action.

Examples:

- defeating enemy
- completing stage
- achievement

---

# Technical Terms

---

# Data Driven

## Definition

An architecture where behavior is controlled by external data instead of hardcoded values.

---

# Component Based Design

## Definition

A design approach where objects are created by combining reusable components.

---

# Object Pool

## Definition

A memory optimization technique where frequently created objects are reused.

Examples:

- projectiles
- effects
- damage numbers

---

# Dependency

## Definition

A relationship where one system requires another system.

Dependencies should always flow:

```
Game

↓

Engine

↓

Godot
```

---

# API

## Definition

A defined interface that allows systems to communicate.

---

# Specification (SPEC)

## Definition

A detailed document describing how a system should work before implementation.

Example:

```
SPEC-0001-RESOURCE-SYSTEM.md
```

---

# Architecture Decision Record (ADR)

## Definition

A document recording an important architectural decision.

ADR decisions are historical records.

---

# Request For Comments (RFC)

## Definition

A proposal document used before making a significant change.

---

# Naming Rules

The following naming rules are official.

---

## Classes

PascalCase

Example:

```
HealthComponent
EnemyFactory
CombatSystem
```

---

## Functions

snake_case

Example:

```
calculate_damage()

spawn_enemy()
```

---

## Resources

Descriptive names.

Example:

```
goblin_basic.tres

arrow_tower.tres
```

---

## Files

Uppercase document names.

Example:

```
ARCHITECTURE_OVERVIEW.md

SPEC-0001-RESOURCE-SYSTEM.md
```

---

# Final Rule

When a new concept is introduced into the project, it must be added to this glossary before being used widely.

---

# End of Document
