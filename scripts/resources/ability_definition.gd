## Data-driven ability definition (SPEC-0015).
##
## Two effect archetypes ship with the vertical slice; the definition shape
## stays extensible for further effect types without breaking content.
class_name AbilityDefinition
extends GameResource

enum EffectType { AREA_DAMAGE, FREEZE }

@export var icon_color: Color = Color.ORANGE
@export var cooldown_seconds: float = 20.0
## Gold price charged on activation (0 = free ability).
@export var gold_cost: int = 0
@export var cast_delay_seconds: float = 0.0
@export var radius: float = 140.0
@export var effect_type: EffectType = EffectType.AREA_DAMAGE
## AREA_DAMAGE: physical-independent damage type dealt inside radius.
@export var damage_type: DamageTypes.Type = DamageTypes.Type.FIRE
@export var damage: int = 60
## FREEZE: duration enemies are stopped.
@export var freeze_duration: float = 3.0


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if cooldown_seconds <= 0.0:
		errors.append("%s: cooldown must be > 0" % id)
	if radius <= 0.0:
		errors.append("%s: radius must be > 0" % id)
	if gold_cost < 0:
		errors.append("%s: gold_cost must be >= 0" % id)
	match effect_type:
		EffectType.AREA_DAMAGE:
			if damage <= 0:
				errors.append("%s: area damage abilities need damage > 0" % id)
			if cast_delay_seconds < 0.0:
				errors.append("%s: cast_delay must be >= 0" % id)
		EffectType.FREEZE:
			if freeze_duration <= 0.0:
				errors.append("%s: freeze needs duration > 0" % id)
	return report
