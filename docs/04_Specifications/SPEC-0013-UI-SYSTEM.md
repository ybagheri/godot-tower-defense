---
Document ID: SPEC-0013
Title: UI System Specification
Version: 1.0.0
Status: Approved
Owner: Game Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0004 Event System
  - SPEC-0007 Tower System
  - SPEC-0010 Economy System
  - SPEC-0011 Progression System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0013: UI System

# Purpose

This document defines the UI System architecture for the
**godot-tower-defense** framework.

The UI System manages:

- game HUD
- menus
- player information
- tower interaction
- notifications
- mobile controls

---

# Core Principle

## UI Displays State And Sends Intent

UI does not contain gameplay logic.

Example:

Wrong:

```
UpgradeButton

changes Tower Damage
```

---

Correct:

```
UpgradeButton

 |

Upgrade Request

 |

Tower System

 |

Update State

 |

UI Refresh
```

---

# Goals

The UI System must provide:

- clear gameplay information
- mobile friendly controls
- responsive layout
- separation from gameplay
- easy localization

---

# Non Goals

UI System does not:

- calculate damage
- create towers
- manage economy
- control waves

---

# Architecture

```
Gameplay Systems

        |

        v

Events

        |

        v

UI Controllers

        |

        v

UI Components

```

---

# UI Layers

The game UI is divided into:

```
HUD Layer

Interaction Layer

Menu Layer

Popup Layer

Notification Layer
```

---

# HUD Layer

Always visible during gameplay.

Contains:

```
Gold Display

Wave Counter

Castle Health

Lives

Speed Control

Pause Button
```

---

# HUD Example

```
+--------------------------------+

Gold: 500        Wave 5/20


              Map


Castle HP: 80%


[Tower Menu]        [Pause]

+--------------------------------+
```

---

# Economy UI

Displays:

```
Current Gold

Income Changes

Purchase Status
```

---

Example:

When enemy dies:

```
+10 Gold
```

---

# Wave UI

Displays:

```
Current Wave

Enemies Remaining

Next Wave Timer
```

---

States:

```
Preparing

Active

Completed

Boss Wave
```

---

# Castle Health UI

Displays:

```
Current Health

Maximum Health
```

---

Events:

```
CastleDamagedEvent

CastleDestroyedEvent
```

---

# Tower Selection UI

When player taps build area:

```
Open Tower Menu
```

---

Example:

```
Choose Tower


[ Archer ]

[ Cannon ]

[ Magic ]

```

---

# Tower Detail Panel

When tower is selected:

Shows:

```
Level

Damage

Range

Attack Speed

Upgrade Cost
```

---

Example:

```
Archer Tower Lv2


Damage:

50


Upgrade:

200 Gold
```

---

# Upgrade UI

Upgrade button sends:

```
UpgradeTowerRequest
```

---

UI does not:

```
apply upgrade
```

---

# Sell UI

Displays:

```
Tower Value

Refund Amount
```

---

Action:

```
Sell Request
```

---

# Pause Menu

Contains:

```
Resume

Settings

Restart Stage

Exit
```

---

# Game Over UI

Displays:

```
Stage Failed

Wave Reached

Retry

Exit
```

---

# Victory UI

Displays:

```
Stage Completed

Stars Earned

Rewards

Continue
```

---

# Notification System

Used for:

```
Tower Unlocked

Achievement

Reward

Warning
```

---

Example:

```
New Tower Unlocked!
```

---

# UI Events

UI listens to:

```
CurrencyChangedEvent

WaveStartedEvent

WaveCompletedEvent

TowerSelectedEvent

TowerUpgradedEvent

StageCompletedEvent
```

---

# UI Requests

UI sends commands:

```
BuildTowerRequest

UpgradeTowerRequest

SellTowerRequest

PauseGameRequest
```

---

# Mobile Input

The UI supports:

```
Touch

Drag

Tap

Long Press
```

---

# Touch Rules

Important actions:

```
Large Buttons

Clear Feedback

Minimum Touch Size
```

---

# Responsive Design

UI must support:

```
Phone

Tablet

Different Aspect Ratios
```

---

# Localization Support

All text must use:

```
Translation Keys
```

Example:

Instead of:

```
"Upgrade"
```

Use:

```
ui.upgrade
```

---

# Theme System

UI styles are data driven.

Supports:

```
Fantasy Theme

Dark Theme

Seasonal Theme
```

---

# Performance Requirements

UI must:

- avoid unnecessary updates
- update only on events
- minimize animations

---

# Animation Guidelines

Use animations for:

```
Rewards

Unlocks

Damage Feedback

Notifications
```

Avoid excessive animations.

---

# Testing Requirements

## Unit Tests

Required:

- UI state updates
- button actions
- event reactions

---

## Integration Tests

Required:

- build tower through UI
- upgrade tower
- complete wave
- display rewards

---

# Acceptance Criteria

The UI System is accepted when:

✓ UI has no gameplay logic

✓ Systems communicate through events

✓ Mobile controls work

✓ HUD updates correctly

✓ Tower interaction is clear

✓ Different resolutions are supported

---

# Future Extensions

Possible additions:

- controller support
- accessibility options
- UI skins
- animated tutorials
- replay UI

---

# Final Principle

```
Systems decide.

Events notify.

UI communicates.
```

---

# End of Document
