---
Document ID: SPEC-0010
Title: Economy System Specification
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
  - SPEC-0007 Tower System
  - SPEC-0008 Enemy System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0010: Economy System

# Purpose

This document defines the Economy System architecture for the
**godot-tower-defense** framework.

The Economy System manages:

- currencies
- rewards
- costs
- purchases
- upgrades
- refunds
- progression economy

---

# Core Principle

## Economy Controls Value Flow

The Economy System does not decide gameplay.

It manages:

```
Gain

↓

Store

↓

Spend

↓

Reward
```

---

# Goals

The Economy System must provide:

- configurable currencies
- balanced progression
- tower purchasing
- upgrade costs
- rewards
- future expansion support

---

# Non Goals

The Economy System does not:

- create towers
- calculate combat
- spawn enemies
- control waves

---

# Architecture

```
Gameplay Event

       |

       v

Reward Request

       |

       v

Economy System

       |

       +------------+

       |            |

       v            v

 Currency      UI Update

 Storage
```

---

# Currency System

The game supports multiple currencies.

Initial:

```
Gold

Premium Currency (Future)

Experience
```

---

# Gold

Main gameplay currency.

Used for:

```
Building Towers

Upgrading Towers

Buying Abilities
```

---

# Experience

Used for:

```
Hero Progression

Player Level
```

---

# Currency Resource

Each currency is defined by:

```
CurrencyDefinition
```

---

Example:

```
Gold

ID:

currency.gold


Maximum:

999999
```

---

# Player Wallet

The player owns:

```
WalletComponent
```

---

Contains:

```
currency_id

amount
```

---

Example:

```
Gold:

250
```

---

# Currency Operations

The system supports:

```
Add Currency

Remove Currency

Check Balance

Can Afford
```

---

# Purchase Flow

Example:

Building Tower:

```
Player

 |

Select Tower

 |

Request Purchase

 |

EconomySystem

 |

Check Gold

 |

Success

 |

Create Tower
```

---

# Purchase Validation

Before purchase:

Check:

```
Enough Currency

Valid Location

Available Slot

Allowed Tower
```

---

# Cost System

Costs are data driven.

Example:

Tower:

```
Arrow Tower
```

Cost:

```
100 Gold
```

---

# Cost Definition

Contains:

```
currency

amount

requirements
```

---

Example:

```
Upgrade Cost:

Gold:

250

Level Required:

2
```

---

# Reward System

Rewards are generated from gameplay events.

Examples:

```
Enemy Killed

Wave Completed

Stage Completed

Achievement
```

---

# Reward Flow

Example:

Enemy Death:

```
EnemyDiedEvent

        |

        v

RewardSystem

        |

        v

Add Gold

        |

        v

Update UI
```

---

# Reward Definition

Contains:

```
reward_type

amount

conditions
```

---

Example:

```
Goblin Reward:

Gold:

10
```

---

# Enemy Rewards

Enemies have:

```
LootComponent
```

---

Example:

```
Goblin

Reward:

10 Gold


Dragon

Reward:

500 Gold
```

---

# Wave Rewards

Completing waves may give:

```
Gold Bonus

Items

Experience
```

---

Example:

```
Wave 10 Completed

Reward:

500 Gold
```

---

# Tower Upgrade Economy

Upgrade cost is defined by:

```
UpgradeDefinition
```

---

Example:

```
Arrow Tower

Level 1 -> 2

Cost:

150 Gold
```

---

# Upgrade Scaling

Future balance system:

```
Cost = Base Cost * Level Modifier
```

---

Example:

```
Level 1:

100

Level 2:

150

Level 3:

250
```

---

# Tower Selling

Selling returns partial value.

Flow:

```
Sell Tower

 |

Calculate Refund

 |

Remove Tower

 |

Add Currency
```

---

# Refund Formula

Initial:

```
Refund = Total Investment * 0.7
```

---

This value must be configurable.

---

# Economy Events

System emits:

```
CurrencyChangedEvent

PurchaseCompletedEvent

PurchaseFailedEvent

RewardReceivedEvent
```

---

# Save Integration

Economy state must support saving:

```
Gold Amount

Inventory

Unlocked Content
```

---

# Balance Data

Balance values must not be hardcoded.

Stored in:

```
BalanceDefinition
```

---

Contains:

```
Tower Costs

Upgrade Costs

Rewards

Difficulty Multipliers
```

---

# Economy Rules

The system must prevent:

```
Negative Currency

Invalid Purchases

Duplicate Rewards

Overflow
```

---

# Performance Requirements

Economy operations are low frequency.

Priority:

- correctness
- consistency
- persistence

---

# Testing Requirements

## Unit Tests

Required:

- add currency
- remove currency
- affordability check
- reward calculation

---

## Integration Tests

Required:

- kill enemy -> receive gold
- build tower -> spend gold
- upgrade tower -> spend gold

---

# Acceptance Criteria

The Economy System is accepted when:

✓ Currency is data driven

✓ Rewards are event based

✓ Costs are configurable

✓ Purchases are validated

✓ Save system can store economy state

✓ Balance can change without code modification

---

# Future Extensions

Possible additions:

- daily rewards
- shops
- skins
- premium currency
- player inventory
- crafting system

---

# Final Principle

```
Combat creates value.

Economy controls value.

Player decisions create strategy.
```

---

# End of Document
