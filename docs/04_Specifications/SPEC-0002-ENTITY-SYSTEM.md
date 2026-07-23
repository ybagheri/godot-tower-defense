---
Document ID: SPEC-0002
Title: Entity System Specification
Version: 1.0.0
Status: Approved
Owner: Engine Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0001 Resource System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0002: Entity System

# Purpose

This document defines the Entity System architecture for the **godot-tower-defense** framework.

The Entity System manages runtime gameplay objects.

Examples:

- enemies
- towers
- heroes
- projectiles
- effects

---

# Core Principle

## Entities Are Containers Of Capability

An Entity does not define behavior by itself.

An Entity becomes useful by receiving Components.

Example:

```
Enemy Entity

+

Health Component

+

Movement Component

+

Combat Component

+

AI Component
```

---

# Goals

The Entity System must provide:

- runtime object management
- component composition
- lifecycle control
- system compatibility
- efficient creation and destruction
- clean separation of data and behavior

---

# Non Goals

The Entity System does not:

- define gameplay rules
- calculate damage
- control AI
- define enemy statistics

Those belong to Systems and Resources.

---

# Entity Architecture

```
              Definition Resource

                    |

                    v

              Entity Factory

                    |

                    v

              Entity Instance

                    |

        +-----------+-----------+

        |           |           |

        v           v           v

   Component   Component   Component

        |

        v

     Systems
```

---

# Entity Types

The framework supports different entity categories.

---

## Enemy Entity

Examples:

```
Goblin

Orc

Dragon
```

Typical Components:

```
HealthComponent

MovementComponent

TargetComponent

AttackComponent

AIComponent
```

---

## Tower Entity

Examples:

```
Arrow Tower

Magic Tower

Cannon Tower
```

Typical Components:

```
TargetingComponent

AttackComponent

UpgradeComponent

RangeComponent
```

---

## Hero Entity

Examples:

```
Knight

Mage

Archer
```

Typical Components:

```
HealthComponent

MovementComponent

AbilityComponent

ExperienceComponent
```

---

## Projectile Entity

Examples:

```
Arrow

Fireball

Magic Missile
```

Typical Components:

```
MovementComponent

DamageComponent

CollisionComponent
```

---

# Entity Lifecycle

Every entity follows this lifecycle:

```
Created

↓

Initialized

↓

Active

↓

Disabled

↓

Destroyed
```

---

# Creation Flow

```
Request Entity

        |

        v

Factory Receives Definition

        |

        v

Create Scene Instance

        |

        v

Attach Components

        |

        v

Initialize Components

        |

        v

Register With Systems

        |

        v

Entity Active
```

---

# Entity Factory

## Responsibility

Creates runtime entities from definitions.

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

# Factory Rules

Factory:

DO:

- create objects
- attach components
- initialize data

DO NOT:

- calculate combat
- control AI
- manage waves

---

# Entity Base Class

All entities inherit from:

```
GameEntity
```

Responsibilities:

- component container
- lifecycle
- identity
- event communication

---

Example:

```gdscript
class_name GameEntity
extends Node2D


var entity_id: String

var components: Dictionary
```

---

# Component Management

Entities provide component access.

Example:

```gdscript
entity.get_component(HealthComponent)
```

---

# Component Rules

Components are:

- independent
- reusable
- replaceable

---

Example:

An enemy can replace:

```
MovementComponent
```

with:

```
FlyingMovementComponent
```

without changing the Entity.

---

# Entity Tags

Entities support tags.

Examples:

```
enemy

boss

flying

undead

ranged
```

---

Purpose:

Systems can filter entities.

Example:

```
TargetingSystem

Find entities with:

enemy

alive

visible
```

---

# Entity Events

Entities communicate through events.

Examples:

```
entity_spawned

entity_damaged

entity_died

entity_removed
```

---

Example:

```
Enemy

 |

EnemyDiedEvent

 |

+----------------+

|

RewardSystem

|

QuestSystem

|

WaveSystem
```

---

# Entity Pooling

Some entities require pooling.

Recommended:

```
Projectile

Damage Number

Particle Effect
```

---

Lifecycle:

```
Request

↓

Pool Check

↓

Reuse/Create

↓

Active

↓

Return Pool
```

---

# Entity Memory Rules

Entities must avoid:

- unnecessary allocations
- duplicated resources
- expensive initialization

---

# Entity Naming

Runtime names should be descriptive.

Example:

```
enemy_goblin_001
tower_arrow_003
```

---

# Testing Requirements

## Unit Tests

Required:

- component attachment
- lifecycle transitions
- entity creation
- destruction

---

## Integration Tests

Required:

- definition to entity conversion
- factory creation
- system registration

---

# Acceptance Criteria

The Entity System is accepted when:

✓ Entities can be created from definitions

✓ Components can be attached dynamically

✓ Entities have lifecycle management

✓ Systems can access required components

✓ Entities do not contain gameplay rules

✓ Creation is factory based

✓ Pooling can be added without redesign

---

# Future Extensions

Possible additions:

- ECS optimization layer
- multiplayer synchronization
- replay system
- entity serialization

---

# Final Principle

```
Entities exist.

Components describe capability.

Systems create behavior.
```

---

# End of Document
