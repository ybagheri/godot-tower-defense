## Records stage results into persistent progression (SPEC-0011/0012).
##
## Stars follow the SPEC-0011 criteria based on castle health remaining:
## >=70% three stars, >=35% two stars, otherwise one.
class_name ProgressionTracker
extends Node

## SaveManager autoload instance (typed as Node: autoloads carry no class_name).
var save_manager: Node = null
## Callable returning the castle health ratio (0..1) at completion time.
var castle_ratio_provider: Callable = Callable()


func setup(manager: SaveManager) -> void:
	save_manager = manager


func _ready() -> void:
	EventBus.subscribe(GameEvents.STAGE_COMPLETED, _on_stage_completed)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.STAGE_COMPLETED, _on_stage_completed)


static func stars_for_health_ratio(ratio: float) -> int:
	if ratio >= 0.7:
		return 3
	if ratio >= 0.35:
		return 2
	return 1


func record_stage_result(stage_id: String, castle_ratio: float) -> int:
	var stars := stars_for_health_ratio(castle_ratio)
	var progression: Dictionary = save_manager.data.get("progression", {})
	var stages: Dictionary = progression.get("stages", {})
	var existing := int(stages.get(stage_id, 0))
	stages[stage_id] = maxi(existing, stars)
	progression["stages"] = stages
	save_manager.data["progression"] = progression
	save_manager.save_game()
	EventBus.publish(GameEvents.CONTENT_UNLOCKED if stars > existing else GameEvents.SHOW_NOTIFICATION,
			{"stage_id": stage_id, "stars": stars})
	return stars


func stars_for_stage(stage_id: String) -> int:
	var progression: Dictionary = save_manager.data.get("progression", {})
	return int(progression.get("stages", {}).get(stage_id, 0))


func _on_stage_completed(payload: Dictionary) -> void:
	if castle_ratio_provider.is_null():
		return
	record_stage_result(str(payload.get("stage_id", "")),
			castle_ratio_provider.call())
