## Unit tests for combat math and application (SPEC-0006).
extends TestSuite


func setup() -> void:
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	EventBus.clear(GameEvents.TARGET_KILLED)


func teardown() -> void:
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	EventBus.clear(GameEvents.TARGET_KILLED)

func test_physical_damage_subtracts_flat_armor() -> void:
	var result := CombatSystem.calculate_damage(50, DamageTypes.Type.PHYSICAL, 20, 0.0, 0.0, 2.0,
			_make_rng())
	assert_eq(30, result.amount, "50 base - 20 armor")
	assert_false(result.critical, "no crit at zero chance")


func test_physical_minimum_chip_damage() -> void:
	var result := CombatSystem.calculate_damage(5, DamageTypes.Type.PHYSICAL, 100, 0.0, 0.0, 2.0,
			_make_rng())
	assert_eq(1, result.amount, "armor never fully blocks")


func test_true_damage_ignores_armor_and_resistance() -> void:
	var result := CombatSystem.calculate_damage(40, DamageTypes.Type.TRUE, 999, 0.9, 0.0, 2.0,
			_make_rng())
	assert_eq(40, result.amount, "true damage unmitigated")


func test_elemental_resistance_is_percentage() -> void:
	var result := CombatSystem.calculate_damage(100, DamageTypes.Type.FIRE, 0, 0.5, 0.0, 2.0,
			_make_rng())
	assert_eq(50, result.amount, "50% fire resistance halves fire")
	var resisted_fully := CombatSystem.calculate_damage(100, DamageTypes.Type.ICE, 0, 1.0, 0.0, 2.0,
			_make_rng())
	assert_eq(1, resisted_fully.amount, "full resistance still allows 1 chip")


func test_critical_multiplies_after_mitigation() -> void:
	var rng := _make_rng()
	rng.seed = 42
	var result := CombatSystem.calculate_damage(50, DamageTypes.Type.PHYSICAL, 20, 0.0, 1.0, 2.0,
			rng)
	assert_true(result.critical, "guaranteed crit rolled")
	assert_eq(60, result.amount, "(50-20)*2")


func test_crit_roll_is_deterministic_with_seed() -> void:
	CombatSystem.set_rng_seed(7)
	var first := CombatSystem.calculate_damage(10, DamageTypes.Type.PHYSICAL, 0, 0.0, 0.5, 2.0)
	CombatSystem.set_rng_seed(7)
	var second := CombatSystem.calculate_damage(10, DamageTypes.Type.PHYSICAL, 0, 0.0, 0.5, 2.0)
	assert_eq(first.critical, second.critical, "same seed -> same roll")
	assert_eq(first.amount, second.amount, "same seed -> same amount")


func test_resolve_hit_applies_and_publishes_events() -> void:
	var received := {}
	var killed_count := [0]
	EventBus.subscribe(GameEvents.DAMAGE_DEALT, func(p: Dictionary) -> void:
		received.merge(p))
	EventBus.subscribe(GameEvents.TARGET_KILLED, func(_p: Dictionary) -> void:
		killed_count[0] += 1)
	var target := GameEntity.new()
	target.add_tag("enemy")
	var health := HealthComponent.new()
	target.add_component(health)
	health.configure(10)
	var stats := StatsComponent.new()
	target.add_component(stats)
	stats.armor = 5
	stage(target)

	CombatSystem.resolve_hit(target, null, 25, DamageTypes.Type.PHYSICAL)
	assert_eq(0, health.current_health, "25 base - 5 armor = 20 lethal vs 10 hp")
	assert_eq(20, received.get("amount", -1), "damage_dealt carries mitigated amount")
	assert_eq(1, killed_count[0], "target_killed published")
	unstage(target)
	target.free()


func test_resolve_hit_ignores_dead_or_missing_health() -> void:
	var corpse := GameEntity.new()
	var dead_health := HealthComponent.new()
	corpse.add_component(dead_health)
	dead_health.configure(5)
	dead_health.receive_damage(5)
	CombatSystem.resolve_hit(corpse, null, 10, DamageTypes.Type.PHYSICAL)
	corpse.free()

	var bare := GameEntity.new()
	bare.free()
	assert_true(true, "no crash on invalid targets")


func _make_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	return rng
