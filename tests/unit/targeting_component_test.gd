## Unit tests for TargetingComponent priorities and filtering (SPEC-0007).
extends TestSuite

var tower_entity: GameEntity = null
var targeting: TargetingComponent = null


func setup() -> void:
	tower_entity = GameEntity.new()
	tower_entity.position = Vector2.ZERO
	targeting = TargetingComponent.new()
	tower_entity.add_component(targeting)


func teardown() -> void:
	if is_instance_valid(tower_entity):
		tower_entity.free()


func _enemy(position: Vector2, current_health: int = 100, max_health: int = 100,
		flying: bool = false) -> GameEntity:
	var enemy := GameEntity.new()
	enemy.position = position
	enemy.add_tag("enemy")
	if flying:
		enemy.add_tag("flying")
	var health := HealthComponent.new()
	enemy.add_component(health)
	health.configure(max_health)
	health.receive_damage(max_health - current_health)
	return enemy


func _provider(enemies: Array[GameEntity]) -> Callable:
	return func() -> Array: return enemies


func test_selects_only_living_targets_in_range() -> void:
	var alive_near := _enemy(Vector2(100, 0))
	var dead_far := _enemy(Vector2(150, 0))
	dead_near_death(dead_far)
	var out_of_range := _enemy(Vector2(500, 0))
	var candidates: Array[GameEntity] = [alive_near, dead_far, out_of_range]
	targeting.candidate_provider = _provider(candidates)

	var selected := targeting.select_target()
	assert_eq(alive_near, selected, "only living in-range candidate chosen")

	for candidate in candidates:
		if is_instance_valid(candidate):
			candidate.free()


func dead_near_death(enemy: GameEntity) -> void:
	var health: HealthComponent = enemy.get_component(HealthComponent)
	health.receive_damage(health.max_health)


func test_closest_priority() -> void:
	targeting.priority = TargetingComponent.Priority.CLOSEST
	var far := _enemy(Vector2(250, 0))
	var near := _enemy(Vector2(50, 0))
	targeting.candidate_provider = _provider([far, near])
	assert_eq(near, targeting.select_target(), "closest wins")
	near.free()
	far.free()


func test_first_priority_prefers_furthest_progress() -> void:
	targeting.priority = TargetingComponent.Priority.FIRST
	var behind := _enemy(Vector2(50, 0))
	var ahead := _enemy(Vector2(90, 0))
	var path := PathDefinition.new()
	path.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(400, 0)])
	for enemy: GameEntity in [behind, ahead]:
		var movement := MovementComponent.new()
		enemy.add_component(movement)
		movement.setup(path, 100.0)
	# Simulate progress without moving nodes: ahead walked further along route.
	ahead.get_component(MovementComponent).advance(1.0)
	behind.get_component(MovementComponent).advance(0.1)
	targeting.candidate_provider = _provider([behind, ahead])
	assert_eq(ahead, targeting.select_target(), "furthest along the path first")
	behind.free()
	ahead.free()


func test_strongest_and_lowest_health_priorities() -> void:
	var weak := _enemy(Vector2(50, 0), 20, 100)
	var tank := _enemy(Vector2(60, 0), 500, 500)
	targeting.priority = TargetingComponent.Priority.STRONGEST
	targeting.candidate_provider = _provider([weak, tank])
	assert_eq(tank, targeting.select_target(), "strongest by max health")

	targeting.priority = TargetingComponent.Priority.LOWEST_HEALTH
	assert_eq(weak, targeting.select_target(), "lowest current health")
	weak.free()
	tank.free()


func test_flying_filter() -> void:
	targeting.can_target_flying = false
	var flyer := _enemy(Vector2(50, 0), 100, 100, true)
	var walker := _enemy(Vector2(80, 0))
	targeting.candidate_provider = _provider([flyer, walker])
	assert_eq(walker, targeting.select_target(), "ground-only tower skips flyer")
	targeting.can_target_flying = true
	assert_eq(flyer, targeting.select_target(), "with flyers allowed, closer flyer wins")
	flyer.free()
	walker.free()


func test_missing_provider_returns_null() -> void:
	assert_null(targeting.select_target(), "no provider configured yet")
