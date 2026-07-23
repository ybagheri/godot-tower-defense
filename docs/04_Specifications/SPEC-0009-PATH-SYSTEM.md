---
Document ID: SPEC-0009
Title: Path System Specification
Version: 1.0.0
Status: Approved
Owner: Game Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0002 Entity System
  - SPEC-0005 Wave System
  - SPEC-0008 Enemy System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0009: Path System

# Purpose

This document defines the Path System architecture for the
**godot-tower-defense** framework.

The Path System controls:

- enemy routes
- waypoint navigation
- path definitions
- movement directions
- destination detection

---

# Core Principle

## Paths Define Routes, Not Movement

The Path System describes where an entity should go.

The Movement System controls how it moves.

---

Example:

```
Path System

defines:

A -> B -> C -> Castle


Movement System

handles:

speed

direction

animation
```

---

# Goals

The Path System must provide:

- reusable routes
- multiple paths
- waypoint support
- ground and air routes
- easy level design
- mobile performance

---

# Non Goals

The Path System does not:

- move enemies
- control AI
- create enemies
- handle combat

---

# Architecture

```
StageDefinition

        |

        v

PathDefinition

        |

        v

Path Registry

        |

        v

MovementSystem

        |

        v

Enemy Entity
```

---

# Path Definition

A path is defined by:

```
PathDefinition
```

---

Contains:

```
ID

Waypoints

Path Type

Destination

Rules
```

---

Example:

```
Path:

main_route


Waypoints:

P1

P2

P3

Castle
```

---

# Path Types

Initial supported types:

```
Ground Path

Flying Path

Water Path

Teleport Path
```

---

# Ground Path

Used by:

```
Normal enemies

Tanks

Warriors
```

Movement:

```
Waypoint to waypoint
```

---

# Flying Path

Used by:

```
Flying enemies

Dragons

Birds
```

Flying units may ignore:

```
Ground obstacles

Tower placement zones
```

---

# Water Path

Future support:

```
Ships

Water enemies
```

---

# Teleport Path

Used for special enemies.

Example:

```
Portal Enemy

Teleport Point A

to

Teleport Point B
```

---

# Waypoint System

A path consists of waypoints.

Example:

```
Spawn

 |

Waypoint 1

 |

Waypoint 2

 |

Waypoint 3

 |

Castle
```

---

# Waypoint Data

Contains:

```
position

index

optional action
```

---

Example:

```
Waypoint 3

Action:

Turn Left

Spawn Effect
```

---

# Path Following

Movement flow:

```
Enemy

 |

MovementComponent

 |

Requests Path

 |

Gets Next Waypoint

 |

Moves

 |

Waypoint Reached

 |

Next Waypoint
```

---

# Movement Component Integration

MovementComponent stores:

```
current_path

current_waypoint

movement_speed
```

---

# Path Assignment

When enemy spawns:

```
WaveSystem

        |

        v

EnemyFactory

        |

        v

Assign Path

        |

        v

Start Movement
```

---

# Multiple Paths

A stage may contain:

```
Main Route

Secondary Route

Boss Route

Air Route
```

---

Example:

```
             Air Path

Spawn ---------------- Castle


Ground Path

Spawn

 |

 |

Castle
```

---

# Path Selection

Future support:

```
PathSelectionStrategy
```

Examples:

```
Random Path

Strongest Enemy Path

Boss Path
```

---

# Destination Handling

When enemy reaches final waypoint:

Event:

```
EntityReachedDestinationEvent
```

---

Flow:

```
Enemy

 |

Destination Reached

 |

Event

 |

CastleSystem

 |

Damage Castle
```

---

# Path Blocking

Future support:

Towers may influence paths.

Examples:

```
Wall Tower

Barrier

Trap
```

---

# Path Recalculation

Not required initially.

Future:

```
Dynamic Pathfinding
```

---

# Editor Integration

Level designers should be able to create paths visually.

Required:

```
Path Node

Waypoint Nodes

Preview Line
```

---

# Resource Example

```
path_stage_001_main.tres
```

Contains:

```
ID:

stage001.main


Type:

Ground


Waypoints:

10
```

---

# Performance Requirements

Path System must support:

- many enemies
- many simultaneous routes
- low CPU usage

Optimization:

- cached waypoints
- shared path data
- no per-frame path calculations

---

# Testing Requirements

## Unit Tests

Required:

- path loading
- waypoint ordering
- destination detection

---

## Integration Tests

Required:

- enemy receives path
- enemy follows route
- enemy reaches castle

---

# Acceptance Criteria

The Path System is accepted when:

✓ Paths are data driven

✓ Movement is independent

✓ Multiple routes are supported

✓ Flying and ground paths are separated

✓ Level designers can create routes easily

---

# Future Extensions

Possible additions:

- dynamic paths
- path destruction
- enemy path choice AI
- maze mechanics

---

# Final Principle

```
Path tells where.

Movement tells how.

Enemy decides why.
```

---

# End of Document
