## Converts enemy arrivals into castle damage announcements (SPEC-0008/0013).
##
## Pure relay logic: which entity is the castle is injected by battle wiring.
## Defeat handling reacts to castle_destroyed elsewhere; this node only
## damages and announces.
class_name CastleSystem
extends Node

signal castle_damaged(current_health: int, max_health: int)

var castle: GameEntity = null

var _health: HealthComponent = null


## Must be called before adding the node to the tree.
func setup(castle_entity: GameEntity) -> void:
	castle = castle_entity
	if castle != null:
		_health = castle.get_component(HealthComponent)


func current_health() -> int:
	return _health.current_health if _health != null else 0


func max_health() -> int:
	return _health.max_health if _health != null else 0


func is_destroyed() -> bool:
	return _health == null or not _health.is_alive()


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _on_enemy_reached_goal(payload: Dictionary) -> void:
	if _health == null or not _health.is_alive():
		return
	var enemy := payload.get("entity") as GameEntity
	if enemy == null or not is_instance_valid(enemy):
		return
	var loot: LootComponent = enemy.get_component(LootComponent)
	if loot == null:
		return
	_health.receive_damage(loot.damage_to_castle)
	castle_damaged.emit(_health.current_health, _health.max_health)
	EventBus.publish(GameEvents.CASTLE_DAMAGED,
			{"current": _health.current_health, "max": _health.max_health})
	if not _health.is_alive():
		EventBus.publish(GameEvents.CASTLE_DESTROYED, {"castle": castle})
