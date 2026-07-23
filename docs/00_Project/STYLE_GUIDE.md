---
Document ID: PROJ-0004
Title: Coding and Style Guide
Version: 1.0.0
Status: Approved
Owner: Project Architecture
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

# Coding and Style Guide

## Purpose

This document defines the official coding standards for the **godot-tower-defense** project.

The goal is to create code that is:

- readable
- maintainable
- predictable
- scalable
- friendly for human developers and AI assistants

---

# General Philosophy

Code is written for humans first.

The computer executes code.

Humans maintain code.

Therefore:

> Simple and clear code is preferred over clever and complicated code.

---

# Language Standard

## Engine

Godot 4.x

## Language

GDScript 2.0

## Type System

Typed GDScript is mandatory.

---

## Required

Correct:

```gdscript
var health: int = 100
var speed: float = 120.0
var target: Node2D
```

---

Avoid:

```gdscript
var health = 100
var speed = 120
var target = null
```

---

# File Structure Rules

Each script should have one clear responsibility.

A script should not become a "God Object".

---

Recommended:

```
health_component.gd

movement_system.gd

enemy_factory.gd
```

---

Avoid:

```
game_manager.gd

5000 lines
```

---

# Class Naming

Classes use PascalCase.

Examples:

```gdscript
class_name HealthComponent

class_name EnemyFactory

class_name CombatSystem
```

---

# File Naming

Files use snake_case.

Examples:

```
health_component.gd

enemy_factory.gd

combat_system.gd
```

---

# Folder Naming

Folders use lowercase.

Examples:

```
components/

systems/

resources/

services/
```

---

# Constants

Constants use UPPER_SNAKE_CASE.

Example:

```gdscript
const MAX_LEVEL: int = 10

const DEFAULT_SPEED: float = 100.0
```

---

# Variables

Variables use snake_case.

Example:

```gdscript
var current_health: int

var attack_speed: float
```

---

# Functions

Functions use snake_case.

Example:

```gdscript
func calculate_damage() -> int:
    pass
```

---

# Private Members

Private members start with underscore.

Example:

```gdscript
var _current_target: Node

func _update_state():
    pass
```

---

# Signals

Signals use past tense because they represent completed events.

Correct:

```gdscript
signal enemy_died

signal tower_upgraded
```

Avoid:

```gdscript
signal kill_enemy
```

---

# Enums

Enums use PascalCase.

Example:

```gdscript
enum State
{
    Idle,
    Moving,
    Attacking
}
```

---

# Comments

Comments explain WHY.

Not WHAT.

---

Bad:

```gdscript
# Increase health by 10
health += 10
```

---

Good:

```gdscript
# Healing is limited to prevent infinite regeneration loops
health += amount
```

---

# Documentation Comments

Public classes require documentation.

Example:

```gdscript
## Handles health state for any gameplay entity.
class_name HealthComponent
extends Node
```

---

# Class Order

Every script follows this structure:

```gdscript
class_name ExampleClass
extends Node


## Signals

signal example_event


## Constants

const VALUE = 10


## Exported Variables

@export var speed: float


## Public Variables

var current_state


## Private Variables

var _internal_value


## Built-in Methods


func _ready():
    pass


func _process(delta):
    pass


## Public Methods


func do_action():
    pass


## Private Methods


func _update():
    pass
```

---

# Export Variables

Use exports for designer editable values.

Example:

```gdscript
@export var damage: int = 10
```

---

Do not expose internal state.

Avoid:

```gdscript
@export var current_health
```

---

# Resource Rules

Resources contain data.

Resources should not contain complex gameplay logic.

Correct:

```gdscript
class_name EnemyDefinition
extends Resource

@export var max_health: int
@export var speed: float
```

---

Avoid:

```gdscript
func attack_player():
    pass
```

inside Resource.

---

# Component Rules

Components:

- store state
- provide small capabilities
- emit signals

Components should not manage the entire game.

---

# System Rules

Systems:

- process gameplay logic
- operate on components
- remain independent

---

# Scene Rules

Every scene should have one primary responsibility.

Examples:

Good:

```
enemy.tscn

tower.tscn

projectile.tscn
```

---

Avoid:

```
everything.tscn
```

---

# Node Communication Rules

Preferred order:

1. Signals
2. Interfaces
3. Dependency Injection
4. Direct references

---

Avoid:

```gdscript
get_node("../../../../Enemy")
```

---

# Singleton Rules

Autoloads are allowed only for true global services.

Allowed:

```
SaveService

AudioService

SettingsService
```

---

Not allowed:

```
GameEverythingManager
```

---

# Error Handling

Errors should be explicit.

Bad:

```gdscript
if data:
    run()
```

---

Good:

```gdscript
if data == null:
    push_error("Missing enemy definition")
    return
```

---

# Performance Rules

Avoid unnecessary:

- object creation
- node searching
- allocations inside loops

---

Prefer:

- caching references
- object pooling
- batched updates

---

# Mobile Rules

Every system must consider:

- memory usage
- battery usage
- CPU usage

---

# AI Development Rules

When using AI assistants:

The AI must:

1. Read architecture documents first.
2. Follow naming conventions.
3. Avoid creating new patterns without approval.
4. Avoid changing architecture.
5. Update documentation when required.

---

# Code Review Checklist

Before accepting code:

## Architecture

- Does it follow the architecture?

## Responsibility

- Does the class have one purpose?

## Performance

- Is it suitable for Android?

## Documentation

- Is it documented?

## Maintainability

- Can another developer understand it?

---

# Final Rule

Consistency is more important than personal preference.

The project follows this style guide even when individual preferences differ.

---

# End of Document
