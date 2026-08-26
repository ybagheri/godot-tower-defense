## Stage definition owning waves and routes (SPEC-0005/0009).
class_name StageDefinition
extends GameResource

## Ordered waves; index 0 starts first.
@export var waves: Array[WaveDefinition] = []

## Route catalog referenced by spawn groups via path_id.
@export var paths: Dictionary = {}

## Preparation time before each wave (seconds).
@export var prep_time_seconds: float = 5.0

@export_group("Battle Start")
@export var starting_gold: int = 250
@export var castle_max_health: int = 100


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if waves.is_empty():
		errors.append("%s: stage needs at least one wave" % id)
	if castle_max_health <= 0:
		errors.append("%s: castle_max_health must be > 0" % id)
	if starting_gold < 0:
		errors.append("%s: starting_gold must be >= 0" % id)
	if prep_time_seconds < 0.0:
		errors.append("%s: prep_time_seconds must be >= 0" % id)
	for wave: WaveDefinition in waves:
		errors.append_array(wave.validate().errors)
	for path_id_key: String in paths.keys():
		if not (paths[path_id_key] is PathDefinition):
			errors.append("%s: paths['%s'] is not a PathDefinition" % [id, path_id_key])
	return report


## Looks up a route by its catalog key. Named get_route() deliberately:
## Resource already owns get_path() for file paths.
func get_route(route_id: String) -> PathDefinition:
	var path: Variant = paths.get(route_id)
	return path as PathDefinition
