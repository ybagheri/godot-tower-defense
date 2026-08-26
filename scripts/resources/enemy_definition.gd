## Data-driven enemy definition (SPEC-0008).
##
## Describes what an enemy is; systems decide how it behaves. Balance values
## live here so designers tune content without touching gameplay code.
class_name EnemyDefinition
extends GameResource

@export_group("Stats")
@export var max_health: int = 100
@export var speed: float = 80.0
@export var armor: int = 0

@export_group("Resistances (0.0 - 1.0)")
@export var magic_resistance: float = 0.0
@export var fire_resistance: float = 0.0
@export var ice_resistance: float = 0.0
@export var poison_resistance: float = 0.0

@export_group("Rewards & Threat")
@export var reward_gold: int = 10
@export var damage_to_castle: int = 1

@export_group("Flags")
@export var flying: bool = false
@export var is_boss: bool = false

## Cosmetic-only scene (Node2D root with sprites/animations). Combat
## components are always assembled by EnemyFactory regardless (ASSUMPTION A2).
@export var visual_scene: PackedScene


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if max_health <= 0:
		errors.append("%s: max_health must be > 0" % id)
	if speed < 0.0:
		errors.append("%s: speed must be >= 0" % id)
	if armor < 0:
		errors.append("%s: armor must be >= 0" % id)
	for resistance_name: String in ["magic", "fire", "ice", "poison"]:
		var value: float = get(resistance_name + "_resistance")
		if value < 0.0 or value > 1.0:
			errors.append("%s: %s_resistance must be within 0.0..1.0" % [id, resistance_name])
	if reward_gold < 0:
		errors.append("%s: reward_gold must be >= 0" % id)
	if damage_to_castle < 0:
		errors.append("%s: damage_to_castle must be >= 0" % id)
	return report


## Percentage resistance (0.0..1.0) against a damage type. Physical damage
## is mitigated by flat armor instead, TRUE damage ignores everything.
func resistance_for(type: DamageTypes.Type) -> float:
	match type:
		DamageTypes.Type.MAGIC:
			return magic_resistance
		DamageTypes.Type.FIRE:
			return fire_resistance
		DamageTypes.Type.ICE:
			return ice_resistance
		DamageTypes.Type.POISON:
			return poison_resistance
		_:
			return 0.0
