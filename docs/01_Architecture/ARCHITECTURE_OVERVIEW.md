---
Document ID: ARCH-0001
Title: Architecture Overview
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
Related ADR:
  - None
Related RFC:
  - None
---

# Architecture Overview

## Purpose

This document defines the high-level architecture of the **godot-tower-defense** project.

It describes:

- major layers
- responsibilities
- communication rules
- dependency boundaries
- runtime flow

This document is the foundation for all technical specifications.

---

# Architecture Goals

The architecture must provide:

- scalability
- maintainability
- performance
- clean separation between systems
- easy content creation
- AI-assisted development compatibility

---

# High-Level Architecture

The project is divided into two primary domains:

```
+--------------------------------+
|          GAME LAYER            |
|                                |
| Enemies                        |
| Towers                         |
| Heroes                         |
| Stages                         |
| Waves                          |
| UI                             |
| Audio                          |
+--------------------------------+
              |
              |
              v
+--------------------------------+
|         ENGINE LAYER           |
|                                |
| Entity System                  |
| Component System               |
| Combat System                  |
| Event System                   |
| Resource System                |
| Save System                    |
| Object Pool                    |
+--------------------------------+
              |
              |
              v
+--------------------------------+
|          GODOT 4               |
|                                |
| Nodes                          |
| Scenes                         |
| Resources                      |
| Signals                        |
| Rendering                      |
| Physics                        |
+--------------------------------+
```

---

# Core Rule

## Engine Never Depends On Game

The dependency direction is always:

```
Game
 |
 v
Engine
 |
 v
Godot
```

Never:

```
Engine
 |
 v
Game
```

The engine must not know:

- Goblin
- Dragon
- Knight
- Castle
- Campaign

Those belong only to the game layer.

---

# Layer Definitions

---

# Layer 1: Godot Runtime

## Responsibility

Native engine functionality.

Includes:

- Node system
- Scene system
- Resource system
- Rendering
- Physics
- Audio
- Input
- Animation

The project uses Godot features instead of recreating them.

---

# Layer 2: Engine Core

## Responsibility

Reusable gameplay framework.

Location:

```
engine/
```

Contains:

```
core/

entity/

components/

systems/

resources/

services/

utilities/
```

---

# Layer 3: Entity Layer

## Responsibility

Runtime objects inside the game world.

Examples:

- Enemy
- Tower
- Hero
- Projectile

An Entity is a composition of components.

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

+
Loot Component
```

---

# Layer 4: Component Layer

## Responsibility

Store reusable state.

Components do not control the entire gameplay.

Examples:

```
HealthComponent

MovementComponent

AttackComponent

TargetComponent

InventoryComponent
```

---

## Component Rules

A component:

- owns data
- exposes state
- emits events if needed

A component does not:

- manage unrelated systems
- know about other entities
- contain large gameplay logic

---

# Layer 5: System Layer

## Responsibility

Execute gameplay logic.

Examples:

```
CombatSystem

MovementSystem

AISystem

WaveSystem

RewardSystem
```

Systems operate on components.

---

# Layer 6: Resource Layer

## Responsibility

Authoring data.

Resources define content.

Examples:

```
EnemyDefinition

TowerDefinition

StageDefinition

WaveDefinition
```

Resources are edited in Godot Inspector.

---

# Runtime Flow

Example: Enemy Creation

```
Enemy Resource

        |
        v

Entity Factory

        |
        v

Create Entity

        |
        v

Attach Components

        |
        v

Register Systems

        |
        v

Runtime Entity
```

---

# Data Flow

```
.tres Resource

       |
       v

Resource Manager

       |
       v

Factory

       |
       v

Runtime Object

       |
       v

Systems

       |
       v

Events

       |
       v

UI / Save / Analytics
```

---

# Communication Rules

Systems should communicate through:

- Signals
- Events
- Interfaces

Avoid:

- direct references
- circular dependencies
- global access

---

# Event Driven Architecture

Example:

Enemy dies:

```
Enemy

 |
 emits

EnemyDiedEvent

 |
 +----------------+
 |                |
 v                v

RewardSystem   QuestSystem

 |
 v

UI Update
```

The enemy does not know who receives the event.

---

# Scene Architecture

Scenes represent runtime objects.

Examples:

```
scenes/

entities/

enemy.tscn

tower.tscn

hero.tscn


world/

stage.tscn


ui/

hud.tscn
```

---

# Resource Architecture

Resources represent definitions.

Examples:

```
resources/

enemies/

goblin.tres

orc.tres


towers/

arrow.tres

fire.tres


stages/

stage_001.tres
```

---

# Factory Pattern

Objects are created through factories.

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

Benefits:

- centralized creation
- easier testing
- easier future changes

---

# Object Pooling

Objects created frequently should support pooling.

Examples:

- projectiles
- damage numbers
- particles
- temporary effects

Flow:

```
Request Object

      |

Pool Available?

      |

YES ----> Reuse

NO -----> Create

```

---

# Performance Requirements

Architecture must support:

- many enemies
- many projectiles
- frequent effects
- mobile hardware limitations

Optimization techniques:

- object pooling
- caching
- avoiding unnecessary allocations
- batched updates

---

# Testing Strategy

Each layer should be testable independently.

Example:

```
Resource Test

        |

Component Test

        |

System Test

        |

Gameplay Test
```

---

# Future Extension Points

The architecture should allow future additions:

- multiplayer
- mod support
- additional campaigns
- new game modes
- procedural content

without rewriting core systems.

---

# Architecture Acceptance Criteria

The architecture is accepted when:

✓ Engine has no dependency on game content

✓ New enemy can be created through Resource files

✓ New tower does not require engine modification

✓ Systems communicate without circular dependencies

✓ Components remain reusable

✓ Runtime creation is factory based

✓ Performance-critical objects support pooling

---

# Final Architecture Principle

```
Data defines the world.

Components define capability.

Systems define behavior.

Scenes define presentation.

Godot executes the runtime.
```

---

# End of Document
