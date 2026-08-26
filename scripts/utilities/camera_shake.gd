## Trauma-based screen shake (§ polish juice).
##
## Listens to impactful gameplay events itself; gameplay never shakes the
## camera directly. Offset scales with trauma squared so small hits stay
## subtle while castle blows feel heavy.
class_name CameraShake
extends Camera2D

@export var max_offset: float = 10.0
@export var max_roll: float = 0.04
@export var decay_per_second: float = 2.2

var trauma: float = 0.0


func _ready() -> void:
	EventBus.subscribe(GameEvents.CASTLE_DAMAGED, _on_castle_damaged)
	EventBus.subscribe(GameEvents.ABILITY_EXECUTED, _on_ability_executed)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.CASTLE_DAMAGED, _on_castle_damaged)
	EventBus.unsubscribe(GameEvents.ABILITY_EXECUTED, _on_ability_executed)


func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, 1.0)


func advance(delta: float) -> void:
	if trauma <= 0.0:
		return
	trauma = maxf(0.0, trauma - decay_per_second * delta)
	var intensity := trauma * trauma
	offset = Vector2(
		randf_range(-1.0, 1.0) * max_offset * intensity,
		randf_range(-1.0, 1.0) * max_offset * intensity,
	)
	rotation = randf_range(-1.0, 1.0) * max_roll * intensity
	if trauma == 0.0:
		offset = Vector2.ZERO
		rotation = 0.0


func _process(delta: float) -> void:
	advance(delta)


func _on_castle_damaged(_payload: Dictionary) -> void:
	add_trauma(0.35)


func _on_ability_executed(payload: Dictionary) -> void:
	if int(payload.get("hits", 0)) > 0:
		add_trauma(0.25)
