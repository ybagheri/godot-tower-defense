---
Document ID: SPEC-0011
Title: Progression System Specification
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
  - SPEC-0010 Economy System
  - SPEC-0007 Tower System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0011: Progression System

# Purpose

This document defines the Progression System architecture for the
**godot-tower-defense** framework.

The Progression System manages:

- player progression
- content unlocking
- tower availability
- hero progression
- campaign advancement
- permanent improvements

---

# Core Principle

## Progression Creates Long-Term Goals

The player should always have:

- something to unlock
- something to improve
- something to achieve

---

# Goals

The Progression System must provide:

- meaningful advancement
- controlled difficulty curve
- unlock management
- long-term engagement
- save compatibility

---

# Non Goals

The Progression System does not:

- manage combat
- create enemies
- calculate rewards
- control towers

---

# Architecture

```
Gameplay Result

        |

        v

Progression Event

        |

        v

Progression System

        |

+---------------+---------------+

|               |               |

v               v               v

Unlocks      Levels       Upgrades

```

---

# Progression Categories

The system contains:

```
Player Level

Campaign Progress

Tower Unlocks

Hero Progress

Permanent Upgrades
```

---

# Player Level

Represents overall player progress.

---

Contains:

```
level

experience

next_level_requirement
```

---

Example:

```
Level 5

XP:

3500 / 5000
```

---

# Experience System

Experience sources:

```
Complete Stage

Defeat Boss

Complete Challenge

Achievement
```

---

# Level Up Flow

```
Gain XP

 |

Check Requirement

 |

Level Up

 |

Grant Rewards

 |

Unlock Content
```

---

# Level Rewards

Rewards may include:

```
Gold

New Tower

New Hero

Upgrade Point

Ability
```

---

# Unlock System

The Unlock System controls availability.

---

Example:

Before:

```
Fire Tower

Locked
```

After:

```
Player Level 10

Unlocked
```

---

# Unlock Definition

Contains:

```
content_id

requirement

reward
```

---

Example:

```
Unlock:

tower.fire.basic


Requirement:

Level >= 10
```

---

# Content Unlock Types

Supported:

```
Tower Unlock

Hero Unlock

Stage Unlock

Ability Unlock

Upgrade Unlock
```

---

# Campaign Progression

Controls stage advancement.

Structure:

```
Campaign

 |

Chapter 1

 |

Stage 1

Stage 2

Stage 3

```

---

# Stage Completion

When player wins:

```
StageCompletedEvent

        |

        v

ProgressionSystem

        |

        v

Unlock Next Content
```

---

# Star Rating System

Stages may provide ratings.

Example:

```
1 Star

2 Stars

3 Stars
```

---

Criteria:

```
Castle Health Remaining

Completion Time

Special Objectives
```

---

# Hero Progression

Heroes have separate progression.

Contains:

```
Level

Experience

Skills

Equipment
```

---

# Hero Level Up

Flow:

```
Hero XP

 |

Level Increase

 |

Improve Stats

 |

Unlock Ability
```

---

# Tower Mastery

Future system.

Allows permanent tower improvement.

Example:

```
Arrow Tower Mastery Level 5

+10% Damage
```

---

# Permanent Upgrade System

Player can invest resources into permanent bonuses.

Examples:

```
Global Damage +5%

Starting Gold +100

Castle Health +10%
```

---

# Upgrade Definition

Contains:

```
upgrade_id

cost

effect

maximum_level
```

---

# Progression Events

System emits:

```
PlayerLevelUpEvent

ContentUnlockedEvent

StageCompletedEvent

HeroLevelUpEvent
```

---

# Save Integration

Progression state must save:

```
Player Level

XP

Unlocked Content

Completed Stages

Stars

Permanent Upgrades
```

---

# Data Driven Design

Progression values must not be hardcoded.

Stored in:

```
ProgressionDefinition
```

---

Example:

```
Level Requirements

Unlock Rules

Rewards
```

---

# Difficulty Relationship

Progression should not automatically make the game too easy.

Difficulty depends on:

```
Stage Design

Enemy Scaling

Player Power
```

---

# Balance Rules

Avoid:

- unlimited power growth
- mandatory grinding
- useless unlocks

---

# Testing Requirements

## Unit Tests

Required:

- XP calculation
- level up
- unlock validation
- reward granting

---

## Integration Tests

Required:

- finish stage
- gain XP
- unlock tower
- save progress

---

# Acceptance Criteria

The Progression System is accepted when:

✓ Player progress persists

✓ Content can unlock dynamically

✓ Rewards are configurable

✓ Campaign advancement works

✓ Heroes can progress

✓ New unlocks require minimal code

---

# Future Extensions

Possible additions:

- talent trees
- achievements
- daily missions
- challenges
- seasonal progression

---

# Final Principle

```
Economy creates choices.

Progression creates goals.

Content creates experiences.
```

---

# End of Document
