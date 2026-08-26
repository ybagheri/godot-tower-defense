## Central catalog of event names used with the EventBus.
##
## Names follow the project specifications (past tense, snake_case).
## Events describe what already happened; systems decide how to react.
## Payloads are read-only Dictionaries shared with every listener.
class_name GameEvents
extends Object


# --- Gameplay -------------------------------------------------------------

const ENTITY_SPAWNED: StringName = &"entity_spawned"
const ENTITY_DIED: StringName = &"entity_died"

const ENEMY_SPAWNED: StringName = &"enemy_spawned"
const ENEMY_DIED: StringName = &"enemy_died"

const TOWER_BUILT: StringName = &"tower_built"
const TOWER_UPGRADED: StringName = &"tower_upgraded"
const TOWER_SOLD: StringName = &"tower_sold"

const WAVE_STARTED: StringName = &"wave_started"
const WAVE_COMPLETED: StringName = &"wave_completed"
const BOSS_WAVE_STARTED: StringName = &"boss_wave_started"

const STAGE_COMPLETED: StringName = &"stage_completed"
const STAGE_FAILED: StringName = &"stage_failed"


# --- Combat ---------------------------------------------------------------

const ATTACK_STARTED: StringName = &"attack_started"
const DAMAGE_DEALT: StringName = &"damage_dealt"
const CRITICAL_HIT: StringName = &"critical_hit"
const TARGET_KILLED: StringName = &"target_killed"


# --- Economy --------------------------------------------------------------

const GOLD_EARNED: StringName = &"gold_earned"
const CURRENCY_CHANGED: StringName = &"currency_changed"
const REWARD_RECEIVED: StringName = &"reward_received"
const PURCHASE_COMPLETED: StringName = &"purchase_completed"
const PURCHASE_FAILED: StringName = &"purchase_failed"


# --- Castle -----------------------------------------------------------------

const CASTLE_DAMAGED: StringName = &"castle_damaged"
const CASTLE_DESTROYED: StringName = &"castle_destroyed"


# --- Progression ----------------------------------------------------------

const PLAYER_LEVEL_UP: StringName = &"player_level_up"
const HERO_LEVEL_UP: StringName = &"hero_level_up"
const CONTENT_UNLOCKED: StringName = &"content_unlocked"


# --- UI ---------------------------------------------------------------------

const SHOW_NOTIFICATION: StringName = &"show_notification"
const OPEN_MENU: StringName = &"open_menu"


# --- Abilities --------------------------------------------------------------

const ABILITY_CAST_STARTED: StringName = &"ability_cast_started"
const ABILITY_EXECUTED: StringName = &"ability_executed"
const ABILITY_INTERRUPTED: StringName = &"ability_interrupted"
const ABILITY_COOLDOWN_STARTED: StringName = &"ability_cooldown_started"
const ABILITY_COOLDOWN_FINISHED: StringName = &"ability_cooldown_finished"
