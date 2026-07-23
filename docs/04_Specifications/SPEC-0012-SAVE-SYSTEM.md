---
Document ID: SPEC-0012
Title: Save System Specification
Version: 1.0.0
Status: Approved
Owner: Engine Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0010 Economy System
  - SPEC-0011 Progression System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0012: Save System

# Purpose

This document defines the Save System architecture for the
**godot-tower-defense** framework.

The Save System manages:

- player data persistence
- loading game state
- save versioning
- data migration
- configuration storage

---

# Core Principle

## Save Data Is Player State

The Save System stores what the player has achieved.

It does not store temporary gameplay objects.

---

Example:

Save:

```
Player Level

Gold

Unlocked Towers

Completed Stages
```

Not Save:

```
Current Projectile Position

Temporary Enemy Animation

Particle Effects
```

---

# Goals

The Save System must provide:

- reliable persistence
- version compatibility
- safe loading
- corruption handling
- mobile support

---

# Non Goals

The Save System does not:

- manage gameplay logic
- create entities
- control scenes

---

# Architecture

```
Game Systems

      |

      v

Save Data Provider

      |

      v

Save Manager

      |

      v

Storage

```

---

# Save Manager

## Responsibility

Central save service.

Handles:

- saving
- loading
- validation
- version migration

---

Example API:

```gdscript
save_game()

load_game()

delete_save()
```

---

# Storage Format

Initial format:

```
JSON
```

Reason:

- readable
- easy debugging
- portable
- AI friendly

---

Example:

```
user://save/save_001.json
```

---

# Save Structure

Example:

```json
{
 "version": 1,

 "player": {
    "level": 5,
    "experience": 3200
 },

 "economy": {
    "gold": 500
 },

 "progression": {
    "unlocked_towers": [
       "tower.arrow.basic"
    ]
 }
}
```

---

# Save Categories

Save data is divided into:

```
Player Data

Economy Data

Progression Data

Settings Data

Statistics Data
```

---

# Player Data

Contains:

```
player_id

level

experience

creation_date
```

---

# Economy Data

Contains:

```
currencies

inventory

resources
```

---

Example:

```json
{
 "gold":1000
}
```

---

# Progression Data

Contains:

```
completed_stages

unlocked_content

stars
```

---

Example:

```json
{
 "stage_001":3
}
```

---

# Settings Data

Contains:

```
language

sound_volume

music_volume

quality_settings
```

---

# Statistics Data

Contains:

```
total_kills

highest_wave

play_time

games_completed
```

---

# Save Flow

```
Game Event

 |

Request Save

 |

Collect Data

 |

Validate

 |

Serialize

 |

Write File

 |

Confirm Success
```

---

# Load Flow

```
Start Game

 |

Find Save

 |

Read File

 |

Validate Version

 |

Migrate If Needed

 |

Restore Systems

 |

Start Menu
```

---

# Auto Save

The system supports automatic saving.

Triggers:

```
Stage Completed

Major Unlock

Purchase

Level Up
```

---

# Manual Save

Future support:

```
Save Button

Settings Menu
```

---

# Version System

Every save contains:

```
version
```

Example:

```json
{
 "version":1
}
```

---

# Migration System

When save format changes:

```
Old Save

 |

Migration Script

 |

New Save Format
```

---

Example:

Version 1:

```
gold
```

Version 2:

```
currencies.gold
```

---

# Corruption Handling

The system must handle:

- missing file
- invalid JSON
- incompatible version

---

Recovery:

```
Backup Save

Default Save

Error Report
```

---

# Save Security

The system should prevent:

- invalid values
- negative currency
- impossible progression

---

Example:

Invalid:

```
Gold:

999999999999
```

---

# Data Validation

Before loading:

Check:

```
Required fields exist

Values are valid

Version supported
```

---

# Cloud Save Future Support

Architecture should allow:

```
Local Save

        |

        v

Cloud Service

        |

        v

Synchronization
```

---

# Testing Requirements

## Unit Tests

Required:

- serialization
- deserialization
- version validation
- migration

---

## Integration Tests

Required:

- save progression
- close game
- reopen game
- restore state

---

# Acceptance Criteria

The Save System is accepted when:

✓ Player data persists

✓ Save files are versioned

✓ Invalid saves are detected

✓ Migration is possible

✓ Systems can provide data independently

✓ Mobile storage is supported

---

# Future Extensions

Possible additions:

- cloud save
- multiple save slots
- account system
- replay data
- backup management

---

# Final Principle

```
Gameplay creates state.

Save System preserves state.

Load System restores state.
```

---

# End of Document---
Document ID: SPEC-0012
Title: Save System Specification
Version: 1.0.0
Status: Approved
Owner: Engine Architecture
Created: 2026-07-23
Last Updated: 2026-07-23
Dependencies:
  - PROJ-0001 Project Manifest
  - PROJ-0003 Project Glossary
  - ARCH-0001 Architecture Overview
  - SPEC-0010 Economy System
  - SPEC-0011 Progression System
Related ADR:
  - None
Related RFC:
  - None
---

# SPEC-0012: Save System

# Purpose

This document defines the Save System architecture for the
**godot-tower-defense** framework.

The Save System manages:

- player data persistence
- loading game state
- save versioning
- data migration
- configuration storage

---

# Core Principle

## Save Data Is Player State

The Save System stores what the player has achieved.

It does not store temporary gameplay objects.

---

Example:

Save:

```
Player Level

Gold

Unlocked Towers

Completed Stages
```

Not Save:

```
Current Projectile Position

Temporary Enemy Animation

Particle Effects
```

---

# Goals

The Save System must provide:

- reliable persistence
- version compatibility
- safe loading
- corruption handling
- mobile support

---

# Non Goals

The Save System does not:

- manage gameplay logic
- create entities
- control scenes

---

# Architecture

```
Game Systems

      |

      v

Save Data Provider

      |

      v

Save Manager

      |

      v

Storage

```

---

# Save Manager

## Responsibility

Central save service.

Handles:

- saving
- loading
- validation
- version migration

---

Example API:

```gdscript
save_game()

load_game()

delete_save()
```

---

# Storage Format

Initial format:

```
JSON
```

Reason:

- readable
- easy debugging
- portable
- AI friendly

---

Example:

```
user://save/save_001.json
```

---

# Save Structure

Example:

```json
{
 "version": 1,

 "player": {
    "level": 5,
    "experience": 3200
 },

 "economy": {
    "gold": 500
 },

 "progression": {
    "unlocked_towers": [
       "tower.arrow.basic"
    ]
 }
}
```

---

# Save Categories

Save data is divided into:

```
Player Data

Economy Data

Progression Data

Settings Data

Statistics Data
```

---

# Player Data

Contains:

```
player_id

level

experience

creation_date
```

---

# Economy Data

Contains:

```
currencies

inventory

resources
```

---

Example:

```json
{
 "gold":1000
}
```

---

# Progression Data

Contains:

```
completed_stages

unlocked_content

stars
```

---

Example:

```json
{
 "stage_001":3
}
```

---

# Settings Data

Contains:

```
language

sound_volume

music_volume

quality_settings
```

---

# Statistics Data

Contains:

```
total_kills

highest_wave

play_time

games_completed
```

---

# Save Flow

```
Game Event

 |

Request Save

 |

Collect Data

 |

Validate

 |

Serialize

 |

Write File

 |

Confirm Success
```

---

# Load Flow

```
Start Game

 |

Find Save

 |

Read File

 |

Validate Version

 |

Migrate If Needed

 |

Restore Systems

 |

Start Menu
```

---

# Auto Save

The system supports automatic saving.

Triggers:

```
Stage Completed

Major Unlock

Purchase

Level Up
```

---

# Manual Save

Future support:

```
Save Button

Settings Menu
```

---

# Version System

Every save contains:

```
version
```

Example:

```json
{
 "version":1
}
```

---

# Migration System

When save format changes:

```
Old Save

 |

Migration Script

 |

New Save Format
```

---

Example:

Version 1:

```
gold
```

Version 2:

```
currencies.gold
```

---

# Corruption Handling

The system must handle:

- missing file
- invalid JSON
- incompatible version

---

Recovery:

```
Backup Save

Default Save

Error Report
```

---

# Save Security

The system should prevent:

- invalid values
- negative currency
- impossible progression

---

Example:

Invalid:

```
Gold:

999999999999
```

---

# Data Validation

Before loading:

Check:

```
Required fields exist

Values are valid

Version supported
```

---

# Cloud Save Future Support

Architecture should allow:

```
Local Save

        |

        v

Cloud Service

        |

        v

Synchronization
```

---

# Testing Requirements

## Unit Tests

Required:

- serialization
- deserialization
- version validation
- migration

---

## Integration Tests

Required:

- save progression
- close game
- reopen game
- restore state

---

# Acceptance Criteria

The Save System is accepted when:

✓ Player data persists

✓ Save files are versioned

✓ Invalid saves are detected

✓ Migration is possible

✓ Systems can provide data independently

✓ Mobile storage is supported

---

# Future Extensions

Possible additions:

- cloud save
- multiple save slots
- account system
- replay data
- backup management

---

# Final Principle

```
Gameplay creates state.

Save System preserves state.

Load System restores state.
```

---

# End of Document
