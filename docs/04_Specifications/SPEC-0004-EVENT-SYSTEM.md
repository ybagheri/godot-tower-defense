---
Document ID: SPEC-0004
Title: Event System Specification
Version: 1.0.0
Status: Approved
Owner: Engine Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0002 Entity System
  - SPEC-0003 Component System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0004: Event System

# Purpose

This document defines the Event System architecture for the **godot-tower-defense** framework.

The Event System provides communication between independent systems without creating direct dependencies.

---

# Core Principle

## Systems Announce Events, Other Systems React

A system should not know who receives its messages.

Example:

Bad:

```
Enemy

calls

RewardSystem.add_gold()
```

Problem:

Enemy now depends on RewardSystem.

---

Correct:

```
Enemy

emits

EnemyDiedEvent

        |

        +------------+

        |            |

        v            v

RewardSystem    QuestSystem
```

---

# Goals

The Event System must provide:

- loose coupling
- scalable communication
- easy extension
- clean architecture
- testability

---

# Non Goals

The Event System does not:

- contain gameplay logic
- replace all function calls
- manage object lifecycle

---

# Architecture

```
                 Event Producer

                       |

                       v

                 Event Bus

                       |

       +---------------+---------------+

       |               |               |

       v               v               v

   System A        System B        System C
```

---

# Event Types

Events are divided into categories.

---

# Gameplay Events

Events related to game actions.

Examples:

```
EnemySpawnedEvent

EnemyDiedEvent

TowerBuiltEvent

TowerUpgradedEvent

WaveStartedEvent

WaveCompletedEvent
```

---

# Combat Events

Examples:

```
DamageDealtEvent

CriticalHitEvent

TargetDestroyedEvent
```

---

# Economy Events

Examples:

```
GoldEarnedEvent

RewardReceivedEvent

PurchaseCompletedEvent
```

---

# Progression Events

Examples:

```
LevelCompletedEvent

AchievementUnlockedEvent

SkillUnlockedEvent
```

---

# UI Events

Examples:

```
ShowNotificationEvent

OpenMenuEvent
```

---

# Event Structure

Every event contains:

- event type
- timestamp
- source
- payload

---

Example:

```gdscript
class_name EnemyDiedEvent


var source_entity

var enemy_id: String

var reward_value: int
```

---

# Event Bus

## Responsibility

Central communication service.

Responsibilities:

- publish events
- subscribe listeners
- dispatch events

---

# Event Flow Example

Enemy Death:

```
Enemy

 |

Health reaches zero

 |

EnemyDiedEvent

 |

EventBus

 |

+----------------+

|                |

v                v

RewardSystem   WaveSystem

 |

v

UI Update
```

---

# Event Naming Rules

Events use past tense.

Correct:

```
EnemyDiedEvent

TowerBuiltEvent

WaveCompletedEvent
```

Incorrect:

```
KillEnemyEvent

BuildTowerEvent
```

Reason:

Events describe something that already happened.

---

# Event Payload Rules

Events should contain enough information for receivers.

Example:

EnemyDiedEvent:

```
enemy_type

position

killer

reward
```

---

Events should not contain:

- unnecessary objects
- large data
- direct system references

---

# Event Bus API

Conceptual interface:

```gdscript
publish(event)

subscribe(event_type, callback)

unsubscribe(event_type, callback)
```

---

# Signal Integration

Godot Signals are preferred for local Node communication.

Example:

```
HealthComponent

signal died

        |

        v

Entity
```

---

Event Bus is preferred for global communication.

Example:

```
EnemyDiedEvent

        |

        v

RewardSystem
```

---

# Communication Decision Rules

Use:

## Direct Function Call

When:

- same object
- clear ownership

Example:

```
Tower

calls

WeaponComponent
```

---

## Signal

When:

- local Node relationship

Example:

```
Button

pressed

UI Controller
```

---

## Event Bus

When:

- multiple unrelated systems need notification

Example:

```
EnemyDiedEvent
```

---

# Event Lifetime

Events are temporary objects.

Lifecycle:

```
Created

↓

Published

↓

Processed

↓

Released
```

---

# Error Handling

If an event has no listeners:

Allowed.

Example:

```
Achievement system disabled

EnemyDiedEvent still works
```

---

# Performance Requirements

Event System must:

- avoid excessive allocations
- support high frequency events
- avoid unnecessary listeners

---

# High Frequency Events

Examples:

```
DamageEvent

ProjectileHitEvent
```

may require optimization.

Possible solutions:

- pooling
- batching
- specialized dispatching

---

# Testing Requirements

## Unit Tests

Required:

- publish event
- receive event
- unsubscribe listener
- invalid event handling

---

## Integration Tests

Required:

- enemy death flow
- reward generation
- UI update reaction

---

# Acceptance Criteria

The Event System is accepted when:

✓ Systems communicate without direct dependencies

✓ Events have clear ownership

✓ Multiple listeners can react

✓ Removing one system does not break others

✓ Gameplay flow can be traced through events

---

# Future Extensions

Possible additions:

- event recording
- replay system
- analytics pipeline
- multiplayer synchronization
- debugging event viewer

---

# Final Principle

```
Objects perform actions.

Systems process logic.

Events announce changes.
```

---

# End of Document---
