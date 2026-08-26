## One purchasable upgrade step for a tower (SPEC-0007 upgrade definitions).
##
## Bonuses are DELTAS applied cumulatively; negative values allowed.
class_name TowerUpgradeDefinition
extends Resource

@export var cost: int = 100
@export var attack_damage_bonus: int = 0
@export var attack_speed_bonus: float = 0.0
@export var attack_range_bonus: float = 0.0


func validate(context_id: String) -> PackedStringArray:
	var errors := PackedStringArray()
	if cost < 0:
		errors.append("%s: upgrade cost must be >= 0" % context_id)
	return errors
