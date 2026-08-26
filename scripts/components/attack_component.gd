## Attack execution for towers (and future ranged enemies) (SPEC-0006/0007).
##
## Owns cooldown timing; target SELECTION stays in TargetingComponent and
## damage math in CombatSystem. Supports instant hits and pooled projectiles.
class_name AttackComponent
extends GameComponent

const PROJECTILE_POOL_KEY: StringName = &"default_projectile"

var attack_damage: int = 10
var attack_speed: float = 1.0
var damage_type: DamageTypes.Type = DamageTypes.Type.PHYSICAL
var critical_chance: float = 0.0
var critical_multiplier: float = 2.0
var uses_projectiles: bool = false
var projectile_speed: float = 600.0

var _cooldown_remaining: float = 0.0


func configure_from_definition(definition: TowerDefinition) -> void:
	attack_damage = definition.attack_damage
	attack_speed = definition.attack_speed
	damage_type = definition.damage_type
	critical_chance = definition.critical_chance
	critical_multiplier = definition.critical_multiplier
	uses_projectiles = definition.uses_projectiles
	projectile_speed = definition.projectile_speed


func is_ready() -> bool:
	return _cooldown_remaining <= 0.0


## Drives the attack loop; tests call directly for deterministic combat.
func advance(delta: float) -> void:
	_cooldown_remaining -= delta
	if _cooldown_remaining > 0.0:
		return
	var entity := get_entity()
	if entity == null:
		return
	var targeting: TargetingComponent = entity.get_component(TargetingComponent)
	if targeting == null:
		return
	var target := targeting.select_target()
	if target == null:
		return
	_execute_attack(entity, target)
	_cooldown_remaining = 1.0 / maxf(attack_speed, 0.0001)


func _execute_attack(entity: GameEntity, target: GameEntity) -> void:
	var attack := {
		"attacker": entity,
		"damage": attack_damage,
		"type": damage_type,
		"crit_chance": critical_chance,
		"crit_mult": critical_multiplier,
	}
	EventBus.publish(GameEvents.ATTACK_STARTED, {"attacker": entity, "target": target})
	if uses_projectiles:
		_launch_projectile(entity, target, attack)
	else:
		CombatSystem.resolve_hit(target, entity, attack_damage, damage_type,
				critical_chance, critical_multiplier)


func _launch_projectile(entity: GameEntity, target: GameEntity, attack: Dictionary) -> void:
	if not PoolManager.has_pool(PROJECTILE_POOL_KEY):
		PoolManager.register_pool(PROJECTILE_POOL_KEY, _create_projectile, 0, 128)
	var projectile: Projectile = PoolManager.acquire(PROJECTILE_POOL_KEY)
	if projectile == null:
		push_error("AttackComponent: could not acquire projectile")
		return
	var parent := entity.get_parent()
	if parent != null and not projectile.is_inside_tree():
		parent.add_child(projectile)
	projectile.launch(entity.position, target, projectile_speed, attack)


func _create_projectile() -> Node:
	return Projectile.new()


func _process(delta: float) -> void:
	advance(delta)


func on_activated() -> void:
	set_process(true)


func on_deactivated() -> void:
	set_process(false)


func on_removed() -> void:
	set_process(false)
