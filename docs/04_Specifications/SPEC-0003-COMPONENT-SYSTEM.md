---
Document ID: SPEC-0003
Title: Component System Specification
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
  - SPEC-0002 Entity System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0003: Component System

# Purpose

This document defines the architecture and rules of the Component System used by the **godot-tower-defense** framework.

The Component System provides reusable gameplay capabilities that can be attached to Entities.

---

# Core Principle

## Components Provide Capability

A component represents one capability or state.

Examples:

```
Health

Movement

Attack

Targeting

Inventory
```

An Entity becomes functional by combining components.

---

# Design Philosophy

Traditional inheritance:

```
Enemy

 ├── FlyingEnemy

 ├── ArmoredEnemy

 └── FireEnemy
```

creates complexity.

The project uses composition:

```
Enemy

+

Flying Component

+

Armor Component

+

Fire Resistance Component
```

---

# Goals

The Component System must provide:

- reusable gameplay features
- independent development
- easy testing
- flexible entity creation
- minimal inheritance

---

# Non Goals

Components must not:

- control the whole game
- communicate directly with many other components
- contain unrelated features

---

# Component Architecture

```
              Entity

                |

     +----------+----------+

     |          |          |

     v          v          v

 Health     Movement    Attack

 Component  Component   Component

                |

                v

             Systems
```

---

# Component Categories

Components are divided into categories.

---

# 1. State Components

Store data.

Examples:

```
HealthComponent

StatsComponent

InventoryComponent
```

Responsibilities:

- store values
- provide access
- emit changes

---

# 2. Behavior Components

Provide a capability.

Examples:

```
MovementComponent

AttackComponent

AbilityComponent
```

---

# 3. Configuration Components

Connect runtime objects to definitions.

Examples:

```
EnemyConfigComponent

TowerConfigComponent
```

---

# Base Component

All components inherit from:

```
GameComponent
```

---

Example:

```gdscript
class_name GameComponent
extends Node
```

---

# Component Lifecycle

Components follow:

```
Created

↓

Attached

↓

Initialized

↓

Active

↓

Disabled

↓

Removed
```

---

# Component Attachment Flow

```
Entity Created

      |

      v

Factory Reads Definition

      |

      v

Component Created

      |

      v

Component Attached

      |

      v

Component Initialized

```

---

# Component Rules

## Rule 1

One component = one responsibility.

---

Bad:

```
CombatMovementHealthComponent
```

---

Good:

```
CombatComponent

MovementComponent

HealthComponent
```

---

## Rule 2

Components should be reusable.

Example:

HealthComponent can be used by:

- Enemy
- Tower
- Hero
- Castle

---

## Rule 3

Components communicate through events.

Avoid:

```
HealthComponent

calls

RewardSystem
```

---

Preferred:

```
HealthComponent

emits

EntityDiedEvent

        |

        v

RewardSystem
```

---

# Required Core Components

The initial framework includes:

---

# HealthComponent

Purpose:

Manage health state.

Responsibilities:

- current health
- maximum health
- damage reception
- healing

Events:

```
health_changed

damaged

died
```

---

# MovementComponent

Purpose:

Handle movement capability.

Responsibilities:

- position
- speed
- movement state

Events:

```
movement_started

movement_completed
```

---

# AttackComponent

Purpose:

Provide attacking capability.

Responsibilities:

- attack cooldown
- attack execution
- damage generation

Events:

```
attack_started

attack_completed
```

---

# TargetComponent

Purpose:

Manage target selection.

Responsibilities:

- current target
- target validation
- target priority

---

# StatsComponent

Purpose:

Store dynamic gameplay statistics.

Examples:

```
damage

armor

speed

range
```

---

# AbilityComponent

Purpose:

Manage active abilities.

Examples:

```
Fireball

Heal

Freeze
```

---

# UpgradeComponent

Purpose:

Manage progression changes.

Examples:

```
Tower Level 1

Tower Level 2

Tower Level 3
```

---

# Component Communication

Communication priority:

1. Signals
2. Event Bus
3. Interfaces

Avoid direct dependencies.

---

Example:

```
AttackComponent

        |

 emits

        |

DamageEvent

        |

        v

HealthComponent
```

---

# Component Data Flow

```
Resource Definition

        |

        v

Component Configuration

        |

        v

Runtime Component

        |

        v

System Processing
```

---

# Component Access

Entities provide access.

Example:

```gdscript
var health := entity.get_component(
    HealthComponent
)
```

---

# Component Registration

Components register themselves with the Entity.

Example:

```
Entity

Components:

HealthComponent

MovementComponent

AttackComponent
```

---

# Performance Requirements

Components must:

- avoid unnecessary processing
- support disabling
- avoid allocations in update loops

---

# Update Strategy

Not every component updates every frame.

Example:

Movement:

```
Every frame
```

Inventory:

```
Only when changed
```

---

# Testing Requirements

## Unit Tests

Required:

- attach component
- remove component
- initialize component
- emit events

---

## Integration Tests

Required:

- entity with multiple components
- component interaction
- system processing

---

# Acceptance Criteria

The Component System is accepted when:

✓ Components have single responsibilities

✓ Components can be reused

✓ Entities can dynamically receive components

✓ Components communicate through events

✓ Gameplay logic is outside components

✓ Components are testable independently

---

# Future Extensions

Possible additions:

- advanced ECS optimization
- multithreaded processing
- component serialization
- editor component builder

---

# Final Principle

```
Entity = Container

Component = Capability

System = Behavior
```

---

# End of Document
