## Tracks a tower's level and applies definition-driven stat growth
## (SPEC-0007 UpgradeComponent).
##
## Level 1 is the base TowerDefinition itself; each entry of
## TowerDefinition.upgrades raises the level by applying cumulative deltas to
## the sibling AttackComponent.
class_name UpgradeComponent
extends GameComponent

var tower_definition: TowerDefinition = null
var level: int = 1
## Total gold sunk into this tower (base + upgrades); drives sell refunds.
var investment: int = 0


func configure(definition: TowerDefinition) -> void:
	tower_definition = definition
	level = 1
	investment = definition.cost if definition != null else 0


func max_level() -> int:
	if tower_definition == null:
		return 1
	return 1 + tower_definition.upgrades.size()


func is_max_level() -> bool:
	return level >= max_level()


## Cost of the NEXT upgrade, or -1 when already at max level.
func next_upgrade_cost() -> int:
	if is_max_level() or tower_definition == null:
		return -1
	return tower_definition.upgrades[level - 1].cost


## Applies the next upgrade to [param attack]. Returns false when maxed.
## Payment validation belongs to BuildingSystem, not here.
func apply_next(attack: AttackComponent) -> bool:
	if is_max_level() or tower_definition == null:
		return false
	var upgrade := tower_definition.upgrades[level - 1]
	attack.attack_damage += upgrade.attack_damage_bonus
	attack.attack_speed += upgrade.attack_speed_bonus
	var targeting: TargetingComponent = get_entity().get_component(TargetingComponent)
	if targeting != null:
		targeting.range_px += upgrade.attack_range_bonus
	investment += upgrade.cost
	level += 1
	return true
