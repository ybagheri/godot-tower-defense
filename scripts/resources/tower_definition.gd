## Data-driven tower definition (SPEC-0007).
##
## One resource describes a full tower baseline; upgrades will later modify
## these stats through UpgradeDefinitions without code changes.
class_name TowerDefinition
extends GameResource

@export_group("Combat")
@export var attack_damage: int = 25
@export var attack_speed: float = 1.5
@export var attack_range: float = 300.0
@export var damage_type: DamageTypes.Type = DamageTypes.Type.PHYSICAL

@export_group("Critical Hits")
@export var critical_chance: float = 0.0
@export var critical_multiplier: float = 2.0

@export_group("Projectile")
## When true the attack spawns a pooled chasing projectile instead of an
## instant hit; projectile flight is purely positional (no scene required).
@export var uses_projectiles: bool = false
@export var projectile_speed: float = 600.0

@export_group("Economy")
@export var cost: int = 100

@export_group("Targeting")
@export var targeting_priority: TargetingComponent.Priority = TargetingComponent.Priority.FIRST


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if attack_damage < 0:
		errors.append("%s: attack_damage must be >= 0" % id)
	if attack_speed <= 0.0:
		errors.append("%s: attack_speed must be > 0" % id)
	if attack_range <= 0.0:
		errors.append("%s: attack_range must be > 0" % id)
	if critical_chance < 0.0 or critical_chance > 1.0:
		errors.append("%s: critical_chance must be within 0.0..1.0" % id)
	if critical_multiplier < 1.0:
		errors.append("%s: critical_multiplier must be >= 1.0" % id)
	if uses_projectiles and projectile_speed <= 0.0:
		errors.append("%s: projectile_speed must be > 0 when using projectiles" % id)
	if cost < 0:
		errors.append("%s: cost must be >= 0" % id)
	return report
