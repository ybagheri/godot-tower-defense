## Deterministic combat math and damage application (SPEC-0006).
##
## All damage flows through here; entities never calculate damage themselves.
##
## Formulas (documented for designers):
##   PHYSICAL: max(1, base - armor)          # flat armor, always >= 1 chip
##   TRUE:     base                          # ignores armor & resistances
##   others:   max(1, base * (1 - resistance))  # percentage resistance
##   critical: rolls AFTER mitigation, multiplies the mitigated amount.
class_name CombatSystem
extends RefCounted

static var _rng := RandomNumberGenerator.new()


## Seeds the shared RNG. Tests seed fixed values for deterministic crits.
static func set_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


## Pure calculation; no state is modified. Returns
## {"amount": int, "critical": bool}.
static func calculate_damage(
		base_damage: int,
		type: DamageTypes.Type,
		armor: int,
		resistance: float,
		critical_chance: float,
		critical_multiplier: float,
		rng: RandomNumberGenerator = null) -> Dictionary:
	var generator := rng if rng != null else _rng
	var amount := float(base_damage)
	match type:
		DamageTypes.Type.PHYSICAL:
			amount = maxf(1.0, amount - float(armor))
		DamageTypes.Type.TRUE:
			pass
		_:
			var clamped := clampf(resistance, 0.0, 1.0)
			amount = maxf(1.0, amount * (1.0 - clamped))
	var critical := false
	if critical_chance > 0.0 and generator.randf() < critical_chance:
		critical = true
		amount *= maxf(1.0, critical_multiplier)
	return {"amount": roundi(amount), "critical": critical}


## Calculates damage against a target's StatsComponent and applies it to its
## HealthComponent. Publishes damage_dealt and, on kill, target_killed.
## Safe to call on missing/dead targets: the hit is silently ignored.
static func resolve_hit(target: GameEntity, attacker: GameEntity, base_damage: int,
		type: DamageTypes.Type, critical_chance: float = 0.0,
		critical_multiplier: float = 2.0, rng: RandomNumberGenerator = null) -> void:
	if target == null or not is_instance_valid(target):
		return
	var health: HealthComponent = target.get_component(HealthComponent)
	if health == null or not health.is_alive():
		return

	var armor := 0
	var resistance := 0.0
	var stats: StatsComponent = target.get_component(StatsComponent)
	if stats != null:
		armor = stats.armor
		resistance = stats.resistance_for(type)

	var result := calculate_damage(base_damage, type, armor, resistance,
			critical_chance, critical_multiplier, rng)
	health.receive_damage(result.amount)

	EventBus.publish(GameEvents.DAMAGE_DEALT, {
		"target": target,
		"attacker": attacker,
		"amount": result.amount,
		"type": type,
		"critical": result.critical,
	})
	if not health.is_alive():
		EventBus.publish(GameEvents.TARGET_KILLED, {"target": target, "attacker": attacker})
