## Opt-in event logger for development and CI smoke runs.
##
## Enabled only when environment variable GTD_EVENT_LOG=1 is set; completely
## inert otherwise (zero cost in production builds). Prints every gameplay
## lifecycle event so headless runs can be verified behaviorally.
extends Node

const WATCHED := {
	"wave_started": 0, "enemy_spawned": 0, "damage_dealt": 0,
	"entity_died": 0, "wave_completed": 0, "castle_damaged": 0,
	"stage_completed": 0, "stage_failed": 0,
}

var _counts: Dictionary = {}


func _ready() -> void:
	if OS.get_environment("GTD_EVENT_LOG") != "1":
		set_process(false)
		return
	_counts = WATCHED.duplicate()
	for event_name: StringName in _counts.keys():
		EventBus.subscribe(event_name, _on_event.bind(event_name))
	print("[EventProbe] watching %d event types" % _counts.size())
	_dump_tree.call_deferred()


func _dump_tree() -> void:
	var root := get_tree().current_scene
	print("[EventProbe] current_scene=", root)
	if root != null:
		for child in root.get_children():
			print("  - ", child.name, " (", child.get_script() if child.get_script() != null else child.get_class(), ")")


func _on_event(_payload: Dictionary, event_name: StringName) -> void:
	_counts[event_name] += 1


## Summary printed when the probe leaves the tree (end of run).
func _exit_tree() -> void:
	if _counts.is_empty():
		return
	print("[EventProbe] summary:")
	for event_name: StringName in _counts.keys():
		print("  %-16s %d" % [event_name, _counts[event_name]])
