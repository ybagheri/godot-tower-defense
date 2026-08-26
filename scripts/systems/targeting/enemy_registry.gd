## Tracks living enemies for targeting queries (SPEC-0007/0008 support).
##
## Membership is fully event-driven: entities enter on entity_spawned (tagged
## "enemy") and leave on death or castle arrival. No gameplay logic lives here.
class_name EnemyRegistry
extends Node

var _enemies: Array[GameEntity] = []


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENEMY_SPAWNED, _on_enemy_spawned)
	EventBus.subscribe(GameEvents.ENEMY_DIED, _on_enemy_gone)
	EventBus.subscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_gone)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENEMY_SPAWNED, _on_enemy_spawned)
	EventBus.unsubscribe(GameEvents.ENEMY_DIED, _on_enemy_gone)
	EventBus.unsubscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_gone)


## Snapshot of currently tracked enemies (copy: callers may mutate freely).
func get_enemies() -> Array[GameEntity]:
	_prune_invalid()
	return _enemies.duplicate()


func count() -> int:
	_prune_invalid()
	return _enemies.size()


func clear() -> void:
	_enemies.clear()


func _on_enemy_spawned(payload: Dictionary) -> void:
	var entity := payload.get("entity") as GameEntity
	if entity != null and is_instance_valid(entity):
		_enemies.append(entity)


func _on_enemy_gone(payload: Dictionary) -> void:
	_forget(payload.get("entity"))


func _forget(entity_variant: Variant) -> void:
	var entity := entity_variant as GameEntity
	if entity != null:
		_enemies.erase(entity)


func _prune_invalid() -> void:
	_enemies = _enemies.filter(func(candidate: GameEntity) -> bool:
		return is_instance_valid(candidate))
