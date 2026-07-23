---
Document ID: SPEC-0008
Title: Enemy System Specification
Version: 1.0.0
Status: Approved
Owner: Game Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0001 Resource System
  - SPEC-0002 Entity System
  - SPEC-0003 Component System
  - SPEC-0005 Wave System
  - SPEC-0006 Combat System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0008: Enemy System

# Purpose

This document defines the architecture of enemies in the
**godot-tower-defense** framework.

The Enemy System manages:

- enemy definitions
- enemy creation
- enemy attributes
- enemy abilities
- enemy categories
- enemy behavior integration

---

# Core Principle

## Enemies Are Configurable Combat Entities

An enemy is not a hardcoded class.

An enemy is an Entity created from data.

Example:

```
Goblin Entity

+

HealthComponent

+

MovementComponent

+

CombatComponent

+

AIComponent

+

LootComponent
```

---

# Goals

The Enemy System must provide:

- many enemy types
- data-driven creation
- different behaviors
- boss support
- special abilities
- scalable difficulty

---

# Non Goals

Enemy System does not:

- create waves
- calculate tower damage
- manage rewards
- control map routes

---

# Architecture

```
EnemyDefinition

        |

        v

EnemyFactory

        |

        v

Enemy Entity

        |

+-------------+-------------+

|             |             |

v             v             v

Movement    Combat        AI

System      System        System

```

---

# Enemy Definition

Every enemy is created from:

```
EnemyDefinition
```

---

Example:

```
Goblin Basic

ID:

enemy.goblin.basic


Stats:

Health:
100

Speed:
80

Armor:
0

Reward:
10
```

---

# Enemy Components

An enemy is built using components.

---

# HealthComponent

Provides:

```
maximum health

current health

damage handling
```

---

# MovementComponent

Provides:

```
movement speed

path following

position
```

---

# TargetComponent

Provides:

```
current objective

target validation
```

---

# CombatComponent

Provides:

```
attack ability

damage output
```

---

# AIComponent

Provides:

```
behavior state

decision making
```

---

# LootComponent

Provides:

```
reward information
```

---

# Enemy Categories

The initial system supports:

```
Basic Enemy

Fast Enemy

Tank Enemy

Flying Enemy

Ranged Enemy

Support Enemy

Boss Enemy
```

---

# Basic Enemy

Purpose:

Standard units.

Example:

```
Goblin

Skeleton

Soldier
```

Characteristics:

- balanced stats
- simple behavior

---

# Fast Enemy

Characteristics:

- low health
- high movement speed

Counter:

- fast attack towers

---

# Tank Enemy

Characteristics:

- high health
- armor

Counter:

- magic towers
- high damage towers

---

# Flying Enemy

Characteristics:

- ignores ground paths

Requires:

```
FlyingMovementComponent
```

---

# Ranged Enemy

Characteristics:

Can attack:

- towers
- castle
- heroes

Requires:

```
AttackComponent
```

---

# Support Enemy

Characteristics:

Provides buffs.

Examples:

```
Healing Enemy

Armor Booster
```

---

# Boss Enemy

Boss is a special enemy type.

Additional components:

```
BossHealthComponent

BossAbilityComponent

PhaseComponent
```

---

# Enemy Lifecycle

```
Created

↓

Spawned

↓

Moving

↓

Engaged

↓

Damaged

↓

Dead

↓

Removed
```

---

# Spawn Flow

```
WaveSystem

        |

        v

EnemyFactory

        |

        v

Enemy Instance

        |

        v

Movement Started
```

---

# Movement Integration

Enemy movement is separated.

Enemy does not know:

- path
- map
- route

Movement System handles:

```
Path

Position

Direction
```

---

# Path System

Enemies follow:

```
PathDefinition
```

Example:

```
Route A

Spawn

 |

Waypoint 1

 |

Waypoint 2

 |

Castle
```

---

# Castle Damage

When enemy reaches destination:

Flow:

```
Enemy

 |

Reached Goal

 |

CastleDamageEvent

 |

CastleHealthComponent
```

---

# Enemy AI

AI behavior is component based.

Examples:

```
NormalAIComponent

AggressiveAIComponent

SupportAIComponent

BossAIComponent
```

---

# Enemy States

Initial states:

```
Spawned

Moving

Attacking

Stunned

Dead
```

---

# Status Effects

Enemies support:

```
Burn

Freeze

Slow

Poison

Stun
```

---

# Resistance System

Enemies may have:

```
Physical Resistance

Magic Resistance

Fire Resistance

Ice Resistance
```

---

# Example:

Dragon:

```
Fire Resistance:

90%

Ice Resistance:

20%
```

---

# Enemy Abilities

Advanced enemies may have abilities.

Examples:

```
Heal Nearby Units

Summon Minions

Shield

Teleport
```

---

Abilities are handled by:

```
AbilitySystem
```

---

# Enemy Events

Enemy System emits:

```
EnemySpawnedEvent

EnemyReachedGoalEvent

EnemyDamagedEvent

EnemyDiedEvent
```

---

# Difficulty Scaling

Enemy difficulty should use:

```
DifficultyProfile
```

---

Example:

Stage 1:

```
Health x1
Damage x1
```

Stage 20:

```
Health x4
Damage x3
```

---

# Performance Requirements

Enemy System must support:

- hundreds of enemies
- mobile devices
- pooled entities

Optimization:

- object pooling
- simplified AI updates
- distance based processing

---

# AI Update Optimization

Not all enemies update every frame.

Example:

Near player:

```
60 FPS
```

Far away:

```
10 FPS
```

---

# Testing Requirements

## Unit Tests

Required:

- enemy creation
- component assignment
- resistance calculation
- state changes

---

## Integration Tests

Required:

- enemy spawns from wave
- enemy reaches castle
- enemy dies
- reward generated

---

# Acceptance Criteria

The Enemy System is accepted when:

✓ Enemies are data driven

✓ New enemies require minimal coding

✓ Bosses can have unique behavior

✓ Movement is separated

✓ Combat is separated

✓ AI is component based

---

# Future Extensions

Possible additions:

- enemy factions
- enemy evolution
- procedural enemies
- elite modifiers
- seasonal enemies

---

# Final Principle

```
EnemyDefinition describes.

EnemyFactory creates.

AI controls.

Combat resolves.
```

---

# End of Document
