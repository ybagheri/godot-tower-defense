## Data-driven wave definition (SPEC-0005).
class_name WaveDefinition
extends GameResource

@export var wave_number: int = 1
@export var spawn_groups: Array[SpawnGroupDefinition] = []
@export var is_boss_wave: bool = false
## Gold granted when the wave completes.
@export var reward_gold: int = 50


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	for group: SpawnGroupDefinition in spawn_groups:
		errors.append_array(group.validate(id))
	return report
