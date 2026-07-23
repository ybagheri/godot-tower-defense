---
Document ID: SPEC-0001
Title: Resource System Specification
Version: 1.0.0
Status: Approved
Owner: Engine Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0001: Resource System

# Purpose

This document defines the design and requirements of the Resource System for the **godot-tower-defense** framework.

The Resource System is responsible for:

- defining gameplay data
- storing configuration
- validating content
- providing data to runtime systems

---

# Core Principle

## Resources Define The World

Resources describe what exists.

They do not execute gameplay.

Example:

A Resource defines:

```
Goblin:

Health = 100

Speed = 80

Damage = 10
```

The runtime systems decide:

- how damage is applied
- how movement works
- how AI behaves

---

# Goals

The Resource System must provide:

- data-driven development
- editor friendly workflow
- validation
- version compatibility
- easy content creation
- AI-friendly structure

---

# Non Goals

The Resource System does not:

- run gameplay logic
- control entities
- update frames
- handle combat

---

# Architecture Position

```
                Resource Files

                    |
                    v

            Resource Registry

                    |
                    v

             Factory Systems

                    |
                    v

            Runtime Entities

                    |
                    v

                 Systems
```

---

# Resource Categories

The system supports the following resource types:

```
Resource

├── EntityDefinition
│
├── ComponentDefinition
│
├── EnemyDefinition
│
├── TowerDefinition
│
├── HeroDefinition
│
├── StageDefinition
│
├── WaveDefinition
│
├── AbilityDefinition
│
├── ItemDefinition
│
├── LootDefinition
│
└── AudioDefinition
```

---

# Base Resource

All gameplay resources inherit from:

```
GameResource
```

Responsibilities:

- identifier
- version
- metadata
- validation support

---

Example:

```gdscript
class_name GameResource
extends Resource


@export var id: String

@export var version: int = 1
```

---

# Resource ID

Every resource requires a unique ID.

Format:

```
category.type.name
```

Examples:

```
enemy.goblin.basic

tower.arrow.basic

hero.knight

stage.001
```

---

# ID Rules

IDs must be:

- unique
- permanent
- lowercase
- searchable

---

# Resource Example

## Enemy Definition

File:

```
goblin_basic.tres
```

Contains:

```
ID

Display Name

Description

Scene Reference

Components

Tags

Loot Definition
```

---

# Component Definitions

Components are attached through resources.

Example:

```
Goblin Definition

Components:

HealthComponentDefinition

MovementComponentDefinition

AttackComponentDefinition

AIComponentDefinition
```

---

# Resource Loading

Resources are loaded through the Resource Registry.

Direct loading inside gameplay systems is prohibited.

Bad:

```gdscript
load("res://enemy/goblin.tres")
```

---

Good:

```gdscript
resource_registry.get("enemy.goblin.basic")
```

---

# Resource Registry

## Purpose

Central access point for resources.

Responsibilities:

- registration
- lookup
- caching
- validation

---

Flow:

```
Game Start

↓

Scan Resources

↓

Validate

↓

Register

↓

Available To Systems
```

---

# Validation System

Every resource must be validated before use.

---

Example:

Enemy Validation:

Required:

```
ID exists

Scene exists

Health exists

Movement exists
```

---

Invalid example:

```
Enemy

Missing Health Component

ERROR
```

---

# Validation Levels

## Error

Game cannot continue.

Example:

Missing required resource.

---

## Warning

Game can continue.

Example:

Missing optional sound effect.

---

# Resource Versioning

Every resource contains:

```
version
```

Example:

```
version = 1
```

---

When structure changes:

Migration is required.

Example:

```
Enemy Resource v1

        |

        v

Migration

        |

        v

Enemy Resource v2
```

---

# Runtime Conversion

Resources are converted into runtime objects.

Example:

```
EnemyDefinition

        |

        v

EnemyFactory

        |

        v

Enemy Entity
```

---

# Factory Requirements

Factories must:

- accept definitions
- create runtime objects
- attach components
- register required systems

Factories must not:

- contain gameplay rules
- modify resources

---

# Editor Requirements

Resources must be editable using Godot Inspector.

Designers should be able to:

- create enemies
- configure towers
- create stages

without writing code.

---

# Folder Convention

Resources are stored:

```
game/

content/

enemies/

towers/

heroes/

stages/

waves/
```

---

Example:

```
game/content/enemies/goblin/goblin_basic.tres
```

---

# Performance Requirements

Resource loading must support:

- caching
- lazy loading where appropriate
- avoiding duplicate loads

---

# Testing Requirements

The Resource System requires:

## Unit Tests

- ID validation
- loading
- version checking
- missing dependency detection

---

## Integration Tests

- resource to entity creation
- factory compatibility

---

# Acceptance Criteria

The Resource System is accepted when:

✓ Resources can define gameplay content

✓ Resources contain no gameplay logic

✓ All resources have unique IDs

✓ Invalid resources are detected

✓ Factories can create runtime objects

✓ Systems do not directly load files

✓ New content can be added without engine changes

---

# Future Extensions

Possible future additions:

- remote content packs
- mod support
- downloadable campaigns
- editor plugins
- resource dependency graphs

---

# Final Principle

```
Resources describe.

Factories create.

Entities exist.

Systems act.
```

---

# End of Document
