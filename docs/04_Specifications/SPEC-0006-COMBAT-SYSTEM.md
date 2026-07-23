---
Document ID: SPEC-0006
Title: Combat System Specification
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
  - SPEC-0003 Component System
  - SPEC-0004 Event System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0006: Combat System

# Purpose

This document defines the Combat System architecture for the **godot-tower-defense** framework.

The Combat System is responsible for:

- attacks
- damage calculation
- damage application
- combat events
- combat interactions

---

# Core Principle

## Combat Is A System, Not An Object

Entities do not calculate combat themselves.

Example:

Wrong:

```
Enemy.attack()

Tower.damage_enemy()
```

---

Correct:

```
AttackComponent

        |

        v

CombatSystem

        |

        v

DamageEvent

        |

        v

HealthComponent
```

---

# Goals

The Combat System must support:

- tower attacks
- enemy attacks
- hero abilities
- different damage types
- armor
- resistance
- critical hits
- status effects
- future expansion

---

# Non Goals

Combat System does not:

- control movement
- select targets
- create waves
- manage rewards

---

# Architecture

```
Attack Source

      |

      v

AttackComponent

      |

      v

CombatSystem

      |

      v

Damage Calculation

      |

      v

DamageEvent

      |

      v

HealthComponent
```

---

# Combat Components

The system uses several components.

---

# AttackComponent

## Responsibility

Defines attack capability.

Contains:

```
attack_speed

attack_range

attack_damage

attack_type
```

---

Example:

Tower:

```
Attack Damage: 50

Range: 300

Speed: 1 attack/sec
```

---

# DamageComponent

## Responsibility

Defines damage output.

Contains:

```
damage_amount

damage_type

source
```

---

# HealthComponent

## Responsibility

Receives damage.

Contains:

```
current_health

max_health
```

---

# ArmorComponent

## Responsibility

Reduces incoming damage.

Contains:

```
armor_value

armor_type
```

---

# Combat Flow

Example:

Tower attacks enemy:

```
Tower

 |

AttackComponent

 |

CombatSystem

 |

Calculate Damage

 |

DamageEvent

 |

Enemy HealthComponent

 |

Death Event
```

---

# Damage Types

The initial system supports:

```
Physical

Magic

Fire

Ice

Poison

True
```

---

# Damage Rules

Damage calculation:

```
Final Damage =

Base Damage

-

Damage Reduction

+

Modifiers
```

---

# Armor System

Armor reduces specific damage types.

Example:

```
Heavy Armor

Strong:

Physical

Weak:

Magic
```

---

# Resistance System

Resistance is percentage based.

Example:

```
Fire Resistance:

50%

Fire Damage:

100

Result:

50 Damage
```

---

# Critical Hit System

Critical hits are handled by CombatSystem.

Parameters:

```
critical_chance

critical_multiplier
```

Example:

```
Damage:

100


Critical:

200
```

---

# Targeting Relationship

Combat does not select targets.

Target selection belongs to:

```
TargetingSystem
```

Flow:

```
TargetingSystem

        |

        v

AttackComponent

        |

        v

CombatSystem
```

---

# Projectile Combat

Some attacks use projectiles.

Example:

Arrow Tower:

```
Tower

 |

Projectile Spawn

 |

Projectile Hit

 |

Damage Event
```

---

Projectile does not calculate damage.

It only delivers:

```
Hit Event
```

---

# Instant Combat

Some attacks are instant.

Example:

```
Lightning Ability
```

Flow:

```
Ability

 |

CombatSystem

 |

Damage Event
```

---

# Area Damage

The system supports area damage.

Example:

```
Explosion

 |

Find Targets

 |

Apply Damage
```

---

# Status Effects

Combat supports temporary effects.

Examples:

```
Burn

Freeze

Slow

Poison
```

---

Status effects are separate components.

Example:

```
BurnEffectComponent
```

---

# Death Flow

When health reaches zero:

```
HealthComponent

        |

        v

EntityDiedEvent

        |

+---------------+

|               |

v               v

RewardSystem  WaveSystem

```

---

# Combat Events

The system emits:

```
AttackStartedEvent

DamageDealtEvent

CriticalHitEvent

TargetKilledEvent

EntityDiedEvent
```

---

# Combat Logging

Debug mode should support:

Example:

```
Arrow Tower

dealt

45 Physical Damage

to

Goblin
```

---

# Performance Requirements

Combat must support:

- many simultaneous attacks
- many projectiles
- frequent damage events

Optimization:

- pooling
- batching
- cached calculations

---

# Testing Requirements

## Unit Tests

Required:

- damage calculation
- armor reduction
- critical chance
- resistance

---

## Integration Tests

Required:

- tower attacks enemy
- enemy dies
- reward triggers
- status effect applied

---

# Acceptance Criteria

The Combat System is accepted when:

✓ All damage goes through CombatSystem

✓ Entities do not calculate damage

✓ Different damage types are supported

✓ Armor and resistance work independently

✓ Combat events are generated

✓ Future abilities can reuse the system

---

# Future Extensions

Possible additions:

- combo attacks
- elemental reactions
- chain attacks
- damage over time
- advanced AI combat

---

# Final Principle

```
Attack requests.

Combat calculates.

Health receives.

Events announce.
```

---

# End of Document
