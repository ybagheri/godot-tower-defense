## Removes finished enemies from the battlefield (SPEC-0008 lifecycle end).
##
## M4 gap fix: death and goal arrival only updated bookkeeping; the visual
## nodes stayed in the tree. Death fades out briefly (readability), goal
## arrivals despawn immediately (the enemy "enters" the castle gate).
class_name EnemyLifecycleSystem
extends Node

## Presentation hook: Callable(pos: Vector2, color_hint: String) fired for
## death/arrival bursts; injected by battle wiring to keep this node
## presentation-free by default.
var vfx_hook: Callable = Callable()


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENEMY_DIED, _on_enemy_died)
	EventBus.subscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENEMY_DIED, _on_enemy_died)
	EventBus.unsubscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _on_enemy_died(payload: Dictionary) -> void:
	var enemy := payload.get("entity") as GameEntity
	if enemy == null or not is_instance_valid(enemy):
		return
	enemy.deactivate()
	_play_burst(enemy.position, "death")
	if enemy.is_inside_tree():
		var tween := enemy.create_tween()
		tween.tween_property(enemy, "modulate:a", 0.0, 0.25)
		tween.tween_callback(enemy.queue_free)
	else:
		enemy.free()


func _on_enemy_reached_goal(payload: Dictionary) -> void:
	var enemy := payload.get("entity") as GameEntity
	if enemy == null or not is_instance_valid(enemy):
		return
	_play_burst(enemy.position, "arrival")
	enemy.queue_free()


func _play_burst(position: Vector2, color_hint: String) -> void:
	if vfx_hook.is_valid():
		vfx_hook.call(position, color_hint)
