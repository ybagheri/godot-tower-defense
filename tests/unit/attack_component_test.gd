## Tests for AttackComponent instant hits and pooled projectiles (SPEC-0006/0007).
extends TestSuite

var tower := GameEntity.new()
var target := GameEntity.new()
var target_health := HealthComponent.new()


func setup() -> void:
	PoolManager.clear_all()
	EventBus.clear(GameEvents.ATTACK_STARTED)

	tower = GameEntity.new()
	var attack := AttackComponent.new()
	tower.add_component(attack)
	var targeting := TargetingComponent.new()
	tower.add_component(targeting)

	target = GameEntity.new()
	target.position = Vector2(100, 0)
	target_health = HealthComponent.new()
	target.add_component(target_health)
	target_health.configure(1000)
	var stats := StatsComponent.new()
	target.add_component(stats)

	var candidates: Array[GameEntity] = [target]
	targeting.candidate_provider = func() -> Array: return candidates
	targeting.range_px = 300.0
	stage(tower)


func teardown() -> void:
	PoolManager.clear_all()
	unstage(tower)
	if is_instance_valid(tower):
		tower.free()
	if is_instance_valid(target):
		target.free()


func _find_flight() -> Projectile:
	for node in _root().get_children():
		if node is Projectile:
			return node
	return null


func test_instant_attack_applies_damage_and_cooldown() -> void:
	var attack: AttackComponent = tower.get_component(AttackComponent)
	attack.attack_damage = 30
	attack.attack_speed = 2.0

	attack.advance(1.0)
	assert_eq(970, target_health.current_health, "first shot lands immediately")
	attack.advance(0.01)
	assert_eq(970, target_health.current_health, "cooldown blocks second shot")
	attack.advance(0.5)
	assert_eq(940, target_health.current_health, "shot after full cooldown")


func test_attack_without_target_waits() -> void:
	var attack: AttackComponent = tower.get_component(AttackComponent)
	attack.attack_damage = 30
	tower.get_component(TargetingComponent).candidate_provider = func() -> Array: return []
	attack.advance(5.0)
	assert_eq(1000, target_health.current_health, "nothing fired without candidates")


func test_projectile_flight_and_pool_return() -> void:
	var attack: AttackComponent = tower.get_component(AttackComponent)
	attack.attack_damage = 25
	attack.uses_projectiles = true
	attack.projectile_speed = 1000.0

	attack.advance(1.0)
	assert_eq(1000, target_health.current_health, "projectile not yet arrived")

	var pool_key: StringName = AttackComponent.PROJECTILE_POOL_KEY
	var flight := _find_flight()
	assert_not_null(flight, "projectile spawned under tower parent")
	if flight == null:
		return
	assert_true(flight.is_in_flight(), "in flight toward target")

	var guard: int = 0
	while flight.is_in_flight() and guard < 200:
		flight.advance(0.02)
		guard += 1
	assert_false(flight.is_in_flight(), "arrived within simulation budget")
	assert_eq(975, target_health.current_health, "impact delivered damage")
	assert_eq(1, PoolManager.idle_count(pool_key), "projectile returned to pool")


func test_attack_started_event_published() -> void:
	var events := [0]
	EventBus.subscribe(GameEvents.ATTACK_STARTED, func(_p: Dictionary) -> void:
		events[0] += 1)
	var attack: AttackComponent = tower.get_component(AttackComponent)
	attack.attack_damage = 5
	attack.advance(1.0)
	assert_eq(1, events[0], "one attack announcement")
