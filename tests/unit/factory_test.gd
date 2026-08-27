## Tests for EnemyFactory and TowerFactory assembly (SPEC-0007/0008).
extends TestSuite

var goblin := EnemyDefinition.new()
var route := PathDefinition.new()


func setup() -> void:
	EventBus.clear(GameEvents.ENEMY_SPAWNED)
	EventBus.clear(GameEvents.TOWER_BUILT)
	EnemyFactory.reset_counter()
	TowerFactory.reset_counter()
	goblin = EnemyDefinition.new()
	goblin.id = "enemy.goblin.basic"
	goblin.max_health = 42
	goblin.speed = 55.0
	goblin.armor = 3
	goblin.reward_gold = 7
	goblin.damage_to_castle = 2
	route = PathDefinition.new()
	route.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(50, 0)])


func teardown() -> void:
	EventBus.clear(GameEvents.ENEMY_SPAWNED)
	EventBus.clear(GameEvents.TOWER_BUILT)


func test_enemy_factory_assembles_components() -> void:
	var spawned_events := [0]
	EventBus.subscribe(GameEvents.ENEMY_SPAWNED, func(_p: Dictionary) -> void:
		spawned_events[0] += 1)

	var enemy := EnemyFactory.create(goblin, route)
	assert_not_null(enemy, "entity created")
	assert_eq("enemy.goblin.basic", enemy.entity_id, "definition id copied")
	assert_true(enemy.name.begins_with("enemy_enemy_goblin_basic_"), "runtime naming")
	assert_true(enemy.has_tag("enemy"), "enemy tag")
	assert_false(enemy.has_tag("flying"), "ground enemy untagged flying")

	var health: HealthComponent = enemy.get_component(HealthComponent)
	assert_not_null(health, "health attached")
	assert_eq(42, health.max_health, "health from definition")
	var movement: MovementComponent = enemy.get_component(MovementComponent)
	assert_eq(55.0, movement.speed, "speed from definition")
	assert_eq(route, movement.current_path, "route assigned")
	var loot: LootComponent = enemy.get_component(LootComponent)
	assert_eq(7, loot.reward_gold, "reward configured")
	assert_eq(2, loot.damage_to_castle, "castle damage configured")
	var stats: StatsComponent = enemy.get_component(StatsComponent)
	assert_eq(3, stats.armor, "armor copied")
	assert_eq(1, spawned_events[0], "spawn event published")
	enemy.free()


func test_enemy_factory_flags() -> void:
	goblin.flying = true
	goblin.is_boss = true
	var enemy := EnemyFactory.create(goblin, route)
	assert_true(enemy.has_tag("flying"), "flying tag applied")
	assert_true(enemy.has_tag("boss"), "boss tag applied")
	enemy.free()


func test_enemy_spawns_on_first_waypoint() -> void:
	route.waypoints = PackedVector2Array([Vector2(120, 80), Vector2(50, 0)])
	var enemy := EnemyFactory.create(goblin, route)
	assert_not_null(enemy, "entity created")
	assert_eq(route.first_waypoint(), enemy.position,
			"spawned on route start, never at container origin")
	enemy.free()


func test_spawn_advances_along_first_segment() -> void:
	var enemy := EnemyFactory.create(goblin, route)
	var movement: MovementComponent = enemy.get_component(MovementComponent)
	movement.advance(0.2)
	assert_almost_eq(11.0, enemy.position.x, 0.001,
			"advanced along segment start->waypoint[1] (55 px/s * 0.2 s)")
	assert_almost_eq(0.0, enemy.position.y, 0.001, "stays on the path line")
	enemy.free()


func test_tower_factory_configures_combat() -> void:
	var built_events := [0]
	EventBus.subscribe(GameEvents.TOWER_BUILT, func(_p: Dictionary) -> void:
		built_events[0] += 1)

	var archer := TowerDefinition.new()
	archer.id = "tower.arrow.test"
	archer.attack_damage = 33
	archer.attack_speed = 2.5
	archer.attack_range = 250.0
	archer.cost = 90

	var provider := func() -> Array: return []
	var tower := TowerFactory.create(archer, Vector2(10, 20), provider)
	assert_not_null(tower, "tower created")
	assert_eq(Vector2(10, 20), tower.position, "position applied")
	assert_true(tower.has_tag("tower"), "tower tag")
	var attack: AttackComponent = tower.get_component(AttackComponent)
	assert_eq(33, attack.attack_damage, "damage configured")
	assert_almost_eq(2.5, attack.attack_speed, 0.001, "speed configured")
	assert_false(attack.uses_projectiles, "instant by default")
	var targeting: TargetingComponent = tower.get_component(TargetingComponent)
	assert_almost_eq(250.0, targeting.range_px, 0.001, "range configured")
	assert_eq(provider, targeting.candidate_provider, "provider injected")
	assert_eq(1, built_events[0], "tower_built published")
	tower.free()
