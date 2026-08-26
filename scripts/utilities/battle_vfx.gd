## Battle presentation layer for gameplay feedback (§21 readability).
##
## Translates gameplay moments into pooled ring bursts. Gameplay systems call
## the public helpers through injected hooks only; nothing here feeds back
## into simulation.
class_name BattleVfx
extends Node2D

const POOL_KEY: StringName = &"vfx_burst"

const DEATH_COLOR := Color(0.75, 0.25, 0.18)
const ARRIVAL_COLOR := Color(0.85, 0.7, 0.3)
const EXPLOSION_COLOR := Color(0.95, 0.45, 0.12)
const FROST_COLOR := Color(0.5, 0.8, 1.0)


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


func spawn_burst(position: Vector2, color: Color, from_radius: float,
		to_radius: float, duration: float) -> void:
	if not PoolManager.has_pool(POOL_KEY):
		PoolManager.register_pool(POOL_KEY, _create_burst, 4, 48)
	var burst: BurstEffect = PoolManager.acquire(POOL_KEY)
	if burst == null:
		return
	burst.position = position
	get_parent().add_child(burst)
	burst.configure(color, from_radius, to_radius, duration)


func _create_burst() -> Node:
	return BurstEffect.new()
