## Translates engine-level entity lifecycle events into game-level enemy
## events (SPEC-0008 event flow).
##
## HealthComponent (engine layer) announces entity_died generically; this
## small relay is where the GAME decides that a tagged enemy has died or
## reached its goal. Systems subscribe to the specific game events.
class_name EnemyEventRelay
extends Node


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENTITY_DIED, _on_entity_died)
	EventBus.subscribe(GameEvents.ENTITY_REACHED_DESTINATION, _on_entity_reached)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENTITY_DIED, _on_entity_died)
	EventBus.unsubscribe(GameEvents.ENTITY_REACHED_DESTINATION, _on_entity_reached)


func _on_entity_died(payload: Dictionary) -> void:
	var entity := payload.get("entity") as GameEntity
	if entity != null and is_instance_valid(entity) and entity.has_tag("enemy"):
		EventBus.publish(GameEvents.ENEMY_DIED, {"entity": entity})


func _on_entity_reached(payload: Dictionary) -> void:
	var entity := payload.get("entity") as GameEntity
	if entity != null and is_instance_valid(entity) and entity.has_tag("enemy"):
		EventBus.publish(GameEvents.ENEMY_REACHED_GOAL, {"entity": entity})
