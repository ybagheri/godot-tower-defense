## Runtime combat statistics copied from an EnemyDefinition at creation
## (SPEC-0003 StatsComponent, SPEC-0008).
##
## Keeping runtime copies decouples live entities from shared resources so
## future buffs/debuffs can modify stats without mutating cached definitions.
class_name StatsComponent
extends GameComponent

var armor: int = 0
var magic_resistance: float = 0.0
var fire_resistance: float = 0.0
var ice_resistance: float = 0.0
var poison_resistance: float = 0.0


func apply_enemy_definition(definition: EnemyDefinition) -> void:
	armor = definition.armor
	magic_resistance = definition.magic_resistance
	fire_resistance = definition.fire_resistance
	ice_resistance = definition.ice_resistance
	poison_resistance = definition.poison_resistance


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
