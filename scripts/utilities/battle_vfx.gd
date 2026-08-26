## Battle presentation layer for gameplay feedback (§21 readability).
##
## Subscribes to combat/economy events itself: presentation reacting to
## announcements is the intended data flow; nothing here feeds back into the
## simulation.
class_name BattleVfx
extends Node2D

const BURST_POOL_KEY: StringName = &"vfx_burst"
const TEXT_POOL_KEY: StringName = &"vfx_text"
const MAX_FLOATING_TEXTS: int = 24

const DEATH_COLOR := Color(0.75, 0.25, 0.18)
const ARRIVAL_COLOR := Color(0.85, 0.7, 0.3)
const EXPLOSION_COLOR := Color(0.95, 0.45, 0.12)
const FROST_COLOR := Color(0.5, 0.8, 1.0)
const DAMAGE_COLOR := Color(1.0, 0.92, 0.75)
const GOLD_COLOR := Color(1.0, 0.82, 0.25)

var _active_texts: int = 0


func _ready() -> void:
	EventBus.subscribe(GameEvents.DAMAGE_DEALT, _on_damage_dealt)
	EventBus.subscribe(GameEvents.GOLD_EARNED, _on_gold_earned)
	EventBus.subscribe(GameEvents.ATTACK_STARTED, _on_attack_started)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.DAMAGE_DEALT, _on_damage_dealt)
	EventBus.unsubscribe(GameEvents.GOLD_EARNED, _on_gold_earned)
	EventBus.unsubscribe(GameEvents.ATTACK_STARTED, _on_attack_started)


func _on_attack_started(payload: Dictionary) -> void:
	var attacker := payload.get("attacker") as GameEntity
	if attacker == null or not is_instance_valid(attacker):
		return
	spawn_burst(attacker.position + Vector2(0, -18), Color(1.0, 0.9, 0.6),
			4.0, 14.0, 0.14)


func play_burst(position: Vector2, color_hint: String) -> void:
	match color_hint:
		"death":
			spawn_burst(position, DEATH_COLOR, 6.0, 26.0, 0.28)
		"arrival":
			spawn_burst(position, ARRIVAL_COLOR, 10.0, 34.0, 0.32)
		_:
			spawn_burst(position, Color.WHITE, 6.0, 24.0, 0.25)


func play_explosion(position: Vector2, radius: float) -> void:
	spawn_burst(position, EXPLOSION_COLOR, radius * 0.35, radius, 0.42)


func play_frost(position: Vector2, radius: float) -> void:
	spawn_burst(position, FROST_COLOR, radius, radius * 0.4, 0.5)
	play_burst(position, "frost")


func spawn_floating_text(position: Vector2, text_value: String,
		color: Color) -> void:
	if reduced_fx_enabled():
		return
	if _active_texts >= MAX_FLOATING_TEXTS:
		return
	if not PoolManager.has_pool(TEXT_POOL_KEY):
		PoolManager.register_pool(TEXT_POOL_KEY, _create_text, 8, MAX_FLOATING_TEXTS)
	var floater: FloatingText = PoolManager.acquire(TEXT_POOL_KEY)
	if floater == null:
		return
	floater.position = position
	get_parent().add_child(floater)
	floater.configure(text_value, color)
	_active_texts += 1
	floater.set_meta(&"vfx_layer", self)


func spawn_burst(position: Vector2, color: Color, from_radius: float,
		to_radius: float, duration: float) -> void:
	if not PoolManager.has_pool(BURST_POOL_KEY):
		PoolManager.register_pool(BURST_POOL_KEY, _create_burst, 4, 48)
	var burst: BurstEffect = PoolManager.acquire(BURST_POOL_KEY)
	if burst == null:
		return
	burst.position = position
	get_parent().add_child(burst)
	burst.configure(color, from_radius, to_radius, duration)


## Called by FloatingText when it returns to its pool.
func notify_text_retired() -> void:
	_active_texts = maxi(_active_texts - 1, 0)


## Accessibility gate (§49): reduced-FX suppresses floating text entirely
## and halves burst counts; read live so the pause toggle applies instantly.
static func reduced_fx_enabled() -> bool:
	var main_loop := Engine.get_main_loop()
	if main_loop == null or not (main_loop is SceneTree):
		return false
	var save: Node = (main_loop as SceneTree).root.get_node_or_null("/root/SaveManager")
	if save == null:
		return false
	return bool(save.get_section("settings").get("reduced_fx", false))


## Live floater count (debug/tests).
func active_text_count() -> int:
	return _active_texts


func _create_burst() -> Node:
	return BurstEffect.new()


func _create_text() -> Node:
	return FloatingText.new()


func _on_damage_dealt(payload: Dictionary) -> void:
	var target := payload.get("target") as GameEntity
	if target == null or not is_instance_valid(target):
		return
	var amount := int(payload.get("amount", 0))
	var critical := bool(payload.get("critical", false))
	var text_value := str(amount) + ("!" if critical else "")
	var color := DAMAGE_COLOR if not critical else Color(1.0, 0.45, 0.3)
	spawn_floating_text(target.position, text_value, color)


func _on_gold_earned(payload: Dictionary) -> void:
	if str(payload.get("source", "")) != "enemy_died":
		return
	spawn_floating_text(payload.get("position", Vector2.ZERO),
			"+{0}".format([int(payload.get("amount", 0))]), GOLD_COLOR)
