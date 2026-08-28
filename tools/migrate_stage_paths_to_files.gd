extends SceneTree

## ONE-SHOT migration (executed 2026-08-27 per SPEC-0016):
##   godot --headless --path . --script tools/migrate_stage_paths_to_files.gd
##
## Moves every embedded PathDefinition sub-resource out of the shipped stage
## .tres files into external resources/paths/<path_id>.tres referenced via
## ExtResource, then stamps each map's Line2D nodes with a "route_id" meta
## binding them to their path-catalog key. Pairing is proven by EXACT
## waypoint/points equality before stamping - mismatches abort loudly.
##
## Invariants afterwards (enforced by tests/unit/content_validation_test.gd):
##   * stage.paths[key] resolves an external PathDefinition resource
##   * every Line2D in a shipped map carries route_id meta covering every
##     catalog key exactly once, with points == that route's waypoints

const STAGES := [
	"res://resources/stages/stage_001_test_range.tres",
	"res://resources/stages/stage_002_twin_roads.tres",
	"res://resources/stages/stage_003_ironwood_pass.tres",
	"res://resources/stages/stage_004_broken_crossroads.tres",
	"res://resources/stages/stage_005_warlords_gate.tres",
]
const PATHS_DIR := "res://resources/paths"


func _init() -> void:
	var failures := 0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PATHS_DIR))
	for stage_path in STAGES:
		var stage := load(stage_path) as StageDefinition
		if stage == null:
			printerr("LOAD FAIL " + stage_path)
			failures += 1
			continue
		var new_paths := {}
		for route_key: String in stage.paths.keys():
			var original: PathDefinition = stage.paths[route_key]
			var out_file := "%s/%s.tres" % [PATHS_DIR, route_key]
			var external := PathDefinition.new()
			external.id = original.id
			external.display_name = original.display_name
			external.waypoints = original.waypoints.duplicate()
			external.path_type = original.path_type
			if ResourceSaver.save(external, out_file) != OK:
				printerr("SAVE FAIL " + out_file)
				failures += 1
				continue
			new_paths[route_key] = load(out_file)
		stage.paths = new_paths
		if ResourceSaver.save(stage, stage_path) != OK:
			printerr("STAGE REWRITE FAIL " + stage_path)
			failures += 1
		else:
			print("stage ok: " + stage_path)
		failures += _sync_map_metas(stage)
	print("MIGRATION DONE failures=%d" % failures)
	quit(1 if failures > 0 else 0)


func _sync_map_metas(stage: StageDefinition) -> int:
	if stage.map_scene == null:
		return 0
	var scene_path: String = stage.map_scene.resource_path
	var root: Node = (load(scene_path) as PackedScene).instantiate()
	var failures := 0
	for line_node in _line2ds(root):
		var matched: String = ""
		for route_key: String in stage.paths.keys():
			var route: PathDefinition = stage.paths[route_key]
			if line_node.points == route.waypoints:
				matched = route_key
				break
		if matched.is_empty():
			printerr("NO ROUTE MATCHES %s/%s" % [scene_path, line_node.name])
			failures += 1
			continue
		line_node.set_meta(&"route_id", matched)
	var packed := PackedScene.new()
	if packed.pack(root) != OK or ResourceSaver.save(packed, scene_path) != OK:
		printerr("MAP REWRITE FAIL " + scene_path)
		failures += 1
	root.free()
	return failures


func _line2ds(root: Node) -> Array[Line2D]:
	var found: Array[Line2D] = []
	for child in root.get_children():
		if child is Line2D:
			found.append(child)
	return found
