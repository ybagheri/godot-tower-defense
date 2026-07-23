---
Document ID: SPEC-0015
Title: Ability System Specification
Version: 1.0.0
Status: Approved
Owner: Game Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - ARCH-0001 Architecture Overview
  - SPEC-0002 Entity System
  - SPEC-0003 Component System
  - SPEC-0004 Event System
  - SPEC-0006 Combat System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0015: Ability System

# Purpose

The Ability System provides a unified framework for all active and passive
abilities used by towers, heroes, enemies and special gameplay mechanics.

Every gameplay ability must be data-driven and reusable.

---

# Core Principle

Abilities define **what can happen**, not **who performs it**.

The same ability can be reused by different entities.

Examples:

- Fireball
- Heal
- Freeze
- Lightning Strike
- Poison Cloud
- Meteor
- Speed Aura
- Shield

---

# Design Goals

The system shall support:

- Active abilities
- Passive abilities
- Area abilities
- Buffs
- Debuffs
- Cooldowns
- Charges
- Chained effects
- Future multiplayer support

---

# Architecture

```
Entity

 |

AbilityComponent

 |

AbilitySystem

 |

AbilityExecutor

 |

Effects

 |

Combat / Economy / UI / Audio
```

---

# Ability Categories

## Offensive

Examples

- Fireball
- Meteor
- Lightning
- Poison

---

## Defensive

Examples

- Shield
- Heal
- Armor Buff

---

## Utility

Examples

- Speed Boost
- Gold Bonus
- Reveal Fog
- Teleport

---

## Passive

Always active.

Examples

- +10% Damage
- +15% Range
- Fire Resistance

---

## Triggered

Activated automatically.

Examples

- On Death
- On Kill
- On Wave Start
- On Castle Damage

---

# Ability Definition

Every ability is defined by an AbilityDefinition Resource.

Contains

- id
- name
- icon
- description
- cooldown
- cost
- cast_time
- duration
- target_rules
- effects

---

Example

```text
ability.fireball.basic
```

---

# Ability Component

Every entity capable of using abilities owns an
AbilityComponent.

Responsibilities

- available abilities
- cooldown tracking
- activation requests
- validation

---

# Ability States

```
Ready

↓

Casting

↓

Executing

↓

Cooldown

↓

Ready
```

---

# Cooldown System

Cooldown is tracked independently for each ability.

Example

```
Fireball

Cooldown

12 sec
```

---

# Charges

Some abilities may have charges.

Example

```
Heal

Charges

3

Recharge

15 sec
```

---

# Cast Time

Abilities may require casting.

Example

```
Meteor

Cast Time

2 seconds
```

Movement rules are configurable.

---

# Target Types

Supported target categories

- Self
- Enemy
- Ally
- Area
- Position
- Path
- Castle
- Tower

---

# Target Validation

Before execution

AbilitySystem verifies

- valid target
- cooldown
- cost
- range
- restrictions

---

# Ability Effects

One ability may contain multiple effects.

Example

Fireball

Effects

- Damage
- Burn
- Explosion
- Sound
- Screen Shake

---

# Effect Types

Supported effects

- Damage
- Heal
- Spawn
- Buff
- Debuff
- Knockback
- Slow
- Freeze
- Burn
- Poison
- Shield

---

# Buff System

Examples

- Damage Increase
- Attack Speed
- Armor
- Range

Buffs contain

- duration
- stacking rule
- source

---

# Debuff System

Examples

- Slow
- Burn
- Silence
- Weakness
- Poison

---

# Area Abilities

Area abilities define

- radius
- shape
- duration

Shapes

- Circle
- Rectangle
- Cone
- Line

---

# Projectile Abilities

Some abilities create projectiles.

Example

```
Fireball

↓

Projectile

↓

Impact

↓

Explosion
```

Projectile behavior belongs to ProjectileSystem.

---

# Chain Abilities

Example

Lightning

```
Enemy A

↓

Enemy B

↓

Enemy C
```

Maximum chain count is configurable.

---

# Summoning

Abilities may create entities.

Examples

- Skeleton
- Wolf
- Golem
- Turret

Creation is delegated to EntityFactory.

---

# Resource Cost

Abilities may consume

- Mana
- Energy
- Gold
- Charges

The Economy System validates payment.

---

# Events

AbilitySystem publishes

- AbilityCastStartedEvent
- AbilityExecutedEvent
- AbilityInterruptedEvent
- AbilityCooldownStartedEvent
- AbilityCooldownFinishedEvent

---

# Audio Integration

Examples

Fireball

↓

Cast Sound

↓

Explosion Sound

---

# Visual Integration

Examples

- Particle Effect
- Flash
- Decal
- Explosion
- Beam
- Aura

Visual effects remain independent from gameplay.

---

# Save Support

Stored information

- unlocked abilities
- cooldown state (if required)
- ability levels

---

# Performance Requirements

The system shall support

- hundreds of simultaneous abilities
- pooled visual effects
- pooled projectiles
- asynchronous loading of heavy assets

---

# Testing Requirements

Unit Tests

- cooldown calculation
- target validation
- effect execution
- charge restoration

Integration Tests

- tower casts ability
- hero casts spell
- enemy uses special ability
- chained effects
- area effects

---

# Acceptance Criteria

The Ability System is accepted when

✓ New abilities require no engine changes

✓ Effects are reusable

✓ Cooldowns work independently

✓ Ability definitions are data driven

✓ Visual and gameplay logic are separated

✓ AI can activate abilities

✓ Heroes and Towers use the same framework

---

# Future Extensions

- Ability trees
- Combo abilities
- Ultimate skills
- Multiplayer synchronization
- Scriptable abilities
- Mod support

---

# Final Principle

```
Ability defines possibility.

Effect defines consequence.

Systems execute behavior.
```

---

# End of Document
