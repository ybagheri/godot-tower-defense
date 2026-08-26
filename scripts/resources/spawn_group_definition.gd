## One spawn group inside a wave: a stream of one enemy type (SPEC-0005).
class_name SpawnGroupDefinition
extends Resource

## EnemyDefinition id ("enemy.goblin.basic"); resolved through ResourceManager.
@export var enemy_id: String = ""
@export var count: int = 10
## Seconds between consecutive spawns of this group.
@export var spawn_interval: float = 1.0
## Seconds to wait before the first spawn of this group.
@export var initial_delay: float = 0.0
## PathDefinition id inside the stage ("stage001.main").
@export var path_id: String = ""


func validate(context_id: String) -> PackedStringArray:
	var errors := PackedStringArray()
	if enemy_id.is_empty():
		errors.append("%s: spawn group missing enemy_id" % context_id)
	if count <= 0:
		errors.append("%s: spawn group count must be > 0" % context_id)
	if spawn_interval < 0.0:
		errors.append("%s: spawn_interval must be >= 0" % context_id)
	if initial_delay < 0.0:
		errors.append("%s: initial_delay must be >= 0" % context_id)
	if path_id.is_empty():
		errors.append("%s: spawn group missing path_id" % context_id)
	return errors
