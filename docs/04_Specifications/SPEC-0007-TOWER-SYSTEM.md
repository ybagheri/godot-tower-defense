---
Document ID: SPEC-0007
Title: Tower System Specification
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
  - SPEC-0006 Combat System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0007: Tower System

# Purpose

This document defines the Tower System architecture for the
**godot-tower-defense** framework.

The Tower System manages:

- tower creation
- tower placement
- tower configuration
- tower upgrades
- tower targeting
- tower abilities
- tower lifecycle

---

# Core Principle

## Towers Are Configurable Combat Entities

A Tower is not a special hardcoded object.

A Tower is an Entity composed of components.

Example:

```
Arrow Tower Entity

+

HealthComponent

+

AttackComponent

+

TargetingComponent

+

UpgradeComponent

+

RangeComponent
```

---

# Goals

The Tower System must provide:

- multiple tower types
- data-driven creation
- upgrade paths
- different attack styles
- flexible targeting
- mobile-friendly performance

---

# Non Goals

Tower System does not:

- calculate damage
- control enemy AI
- manage currency
- manage waves

Those belong to other systems.

---

# Architecture

```
TowerDefinition

        |

        v

TowerFactory

        |

        v

Tower Entity

        |

+---------------+---------------+

|               |               |

v               v               v

Targeting    Attack        Upgrade

System       System        System

```

---

# Tower Definition

Every tower is created from:

```
TowerDefinition
```

---

Example:

```
Arrow Tower

ID:

tower.arrow.basic


Stats:

Damage:
25

Range:
300

Attack Speed:
1.5
```

---

# Tower Categories

Initial categories:

```
Damage Tower

Support Tower

Magic Tower

Special Tower
```

---

# Damage Tower

Purpose:

Direct damage.

Examples:

```
Archer Tower

Cannon Tower

Fire Tower
```

---

# Support Tower

Purpose:

Improve other towers.

Examples:

```
Attack Speed Boost

Range Boost

Slow Aura
```

---

# Magic Tower

Purpose:

Special damage types.

Examples:

```
Lightning

Ice

Poison
```

---

# Special Tower

Purpose:

Unique mechanics.

Examples:

```
Trap Tower

Summoner Tower
```

---

# Tower Lifecycle

```
Available

↓

Selected

↓

Placement Preview

↓

Placed

↓

Active

↓

Upgraded

↓

Sold

↓

Removed
```

---

# Placement System

Tower placement requires:

- valid location
- available resources
- build permission

---

Flow:

```
Player Selects Tower

        |

        v

Placement Preview

        |

        v

Check Location

        |

        v

Check Cost

        |

        v

Create Tower
```

---

# Placement Rules

Invalid placement:

```
Enemy Path

Blocked Area

Outside Map
```

---

Valid placement:

```
Build Zone

Empty Slot

Allowed Terrain
```

---

# Tower Factory

Responsibility:

Create tower entities.

---

Flow:

```
TowerDefinition

        |

        v

TowerFactory

        |

        v

Tower Instance
```

---

Factory does:

✓ Create Scene

✓ Attach Components

✓ Initialize Stats

✓ Register Systems

---

Factory does not:

✗ Calculate damage

✗ Manage upgrades

---

# Tower Components

---

# AttackComponent

Provides:

```
damage

attack speed

attack type
```

---

# TargetingComponent

Provides:

```
target selection

priority rules
```

---

# RangeComponent

Provides:

```
attack radius

range visualization
```

---

# UpgradeComponent

Provides:

```
current level

upgrade path

upgrade cost
```

---

# Tower Targeting

Target selection is separate.

Tower uses:

```
TargetingSystem
```

---

Target priorities:

```
First Enemy

Closest Enemy

Strongest Enemy

Lowest Health Enemy
```

---

# Target Priority Resource

Example:

```
tower.arrow.basic

priority:

First
```

---

# Attack Flow

```
Tower

 |

TargetingSystem

 |

Target Found

 |

AttackComponent

 |

CombatSystem

 |

Damage Applied
```

---

# Tower Upgrade System

Upgrades are data driven.

Example:

```
Arrow Tower Level 1


Damage:
25


Upgrade


Arrow Tower Level 2


Damage:
50
```

---

# Upgrade Definition

Contains:

```
level

cost

stat changes

visual changes

new abilities
```

---

Example:

```
Upgrade:

Level 2

Cost:

100 Gold

Changes:

Damage +25

Range +50
```

---

# Upgrade Paths

The system supports branching upgrades.

Example:

```
          Level 1

             |

        Level 2

          /    \

         /      \

    Fire Path   Speed Path

```

---

# Tower Selling

A tower may be sold.

Flow:

```
Sell Request

        |

Calculate Refund

        |

Remove Tower

        |

Give Currency
```

---

# Refund Rules

Controlled by:

```
Economy System
```

Tower System only requests refund.

---

# Tower Abilities

Advanced towers may have abilities.

Example:

```
Fire Tower

Ability:

Meteor Strike
```

---

Abilities are handled by:

```
AbilitySystem
```

---

# Tower Events

Tower System emits:

```
TowerBuiltEvent

TowerUpgradedEvent

TowerSoldEvent

TowerTargetChangedEvent
```

---

# Performance Requirements

Tower System must support:

- many towers
- frequent target checks
- many projectiles

Optimization:

- target caching
- update intervals
- object pooling

---

# Target Update Optimization

Not every tower checks targets every frame.

Example:

```
Fast Tower:

0.1 sec


Slow Tower:

0.5 sec
```

---

# Testing Requirements

## Unit Tests

Required:

- tower creation
- placement validation
- upgrade calculation
- selling

---

## Integration Tests

Required:

- place tower
- attack enemy
- upgrade tower
- sell tower

---

# Acceptance Criteria

The Tower System is accepted when:

✓ Towers are data driven

✓ New towers require minimal code

✓ Placement is separated from combat

✓ Upgrades are configurable

✓ Targeting is independent

✓ Tower behavior uses existing systems

---

# Future Extensions

Possible additions:

- tower skins
- tower talents
- tower evolution
- cooperative towers
- hero-tower interaction

---

# Final Principle

```
Tower defines strategy.

Targeting chooses opportunity.

Combat resolves conflict.
```

---

# End of Document
