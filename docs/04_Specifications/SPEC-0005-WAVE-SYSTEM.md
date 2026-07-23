---
Document ID: SPEC-0005
Title: Wave System Specification
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
  - SPEC-0004 Event System
  - SPEC-0002 Entity System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0005: Wave System

# Purpose

This document defines the Wave System architecture for the **godot-tower-defense** framework.

The Wave System controls:

- enemy spawning sequences
- wave timing
- spawn groups
- difficulty progression
- wave completion
- battle flow events

---

# Core Principle

## Waves Define The Battle Rhythm

A Tower Defense game is based on controlled pressure.

The Wave System determines:

- when enemies appear
- how many enemies appear
- enemy composition
- difficulty curve

---

# Goals

The Wave System must provide:

- configurable enemy waves
- data-driven design
- predictable difficulty scaling
- support for boss waves
- support for special events
- mobile-friendly performance

---

# Non Goals

The Wave System does not:

- control enemy AI
- calculate combat
- manage tower attacks
- decide rewards

Those belong to other systems.

---

# Architecture Position

```
StageDefinition

       |

       v

WaveDefinition

       |

       v

WaveSystem

       |

       v

EnemyFactory

       |

       v

Enemy Entity

       |

       v

Gameplay Systems
```

---

# Wave Structure

A Wave contains:

```
Wave

|

+-- Spawn Groups

      |

      +-- Enemy Type

      +-- Count

      +-- Delay

      +-- Timing
```

---

# Data Model

Example:

```
Wave 1

Spawn Group A

Enemy:
Goblin

Count:
10

Spawn Interval:
2 seconds


Spawn Group B

Enemy:
Archer

Count:
5

Spawn Interval:
3 seconds
```

---

# Wave Resource

Each wave is represented by:

```
WaveDefinition
```

---

Example:

```gdscript
class_name WaveDefinition
extends Resource


@export var wave_number: int

@export var spawn_groups: Array
```

---

# Spawn Group

A Spawn Group defines:

- enemy type
- amount
- spawn delay
- conditions

---

Example:

```
SpawnGroup

Enemy:
Orc

Count:
20

Initial Delay:
5 seconds
```

---

# Stage Relationship

A Stage owns waves.

Structure:

```
StageDefinition

      |

      +-- Wave 1

      +-- Wave 2

      +-- Wave 3
```

---

# Stage Flow

```
Stage Started

      |

      v

WaveSystem Initialized

      |

      v

Start Wave

      |

      v

Spawn Enemies

      |

      v

Wait Until Completed

      |

      v

Reward Player

      |

      v

Next Wave
```

---

# Wave States

The Wave System uses:

```
Idle

Preparing

Spawning

Active

Completed

Failed
```

---

# State Flow

```
Idle

 |

 v

Preparing

 |

 v

Spawning

 |

 v

Active

 |

 +------------+

 |            |

 v            v

Completed    Failed
```

---

# Spawn System

The Wave System does not create enemies directly.

It requests creation:

```
WaveSystem

        |

        v

EnemyFactory

        |

        v

Enemy Instance
```

---

# Spawn Point System

Enemies are created at Spawn Points.

Spawn Point provides:

- position
- direction
- route

---

Example:

```
SpawnPoint_A

Position:

(100,200)

Path:

MainRoute
```

---

# Multiple Spawn Points

The system supports:

```
North Entrance

South Entrance

Air Entrance
```

---

# Enemy Route Integration

Wave System only creates enemies.

Movement System controls:

```
Enemy

 |

MovementComponent

 |

Path System
```

---

# Difficulty Scaling

Difficulty should not be hardcoded.

It uses:

```
DifficultyProfile
```

---

Example:

```
Stage 1

Enemy Health:
100%

Enemy Count:
100%


Stage 10

Enemy Health:
250%

Enemy Count:
180%
```

---

# Boss Waves

A wave may contain special flags.

Example:

```
is_boss_wave = true
```

---

Boss Wave can trigger:

- special music
- camera effects
- UI warnings

through events.

---

# Wave Events

The Wave System emits:

```
WaveStartedEvent

EnemySpawnedEvent

WaveCompletedEvent

BossWaveStartedEvent

StageCompletedEvent
```

---

# Example Event Flow

```
Wave Completed

        |

        v

WaveCompletedEvent

        |

+---------------+

|               |

v               v

RewardSystem   UI System

        |

        v

Player Reward
```

---

# Wave Speed Control

The system supports:

- normal speed
- fast forward
- pause

Required for mobile usability.

---

# Performance Requirements

Wave System must support:

- many enemies
- multiple spawn groups
- simultaneous spawning

Optimization:

- spawn batching
- object pooling
- delayed creation

---

# Save Support

Future save system must store:

```
Current Stage

Current Wave

Wave State

Spawn Progress
```

---

# Testing Requirements

## Unit Tests

Required:

- wave loading
- spawn group parsing
- state transitions
- completion detection

---

## Integration Tests

Required:

- stage starts wave
- enemies spawn
- wave completes
- reward triggers

---

# Acceptance Criteria

The Wave System is accepted when:

✓ Waves are created through Resources

✓ Enemy creation uses Factory

✓ Wave progression is event driven

✓ Difficulty can scale without code changes

✓ Boss waves are supported

✓ Multiple spawn points are supported

✓ System works independently from combat

---

# Future Extensions

Possible additions:

- random waves
- endless mode
- challenge modes
- seasonal events
- adaptive difficulty

---

# Final Principle

```
WaveSystem creates pressure.

EnemySystem creates behavior.

CombatSystem creates resolution.
```

---

# End of Document
