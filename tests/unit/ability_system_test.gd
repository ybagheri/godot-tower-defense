## Tests for AbilitySystem: arming, costs, cooldowns, damage and freeze
## (SPEC-0015).
extends TestSuite

var wallet := EconomySystem.new()
var registry := EnemyRegistry.new()
var abilities := AbilitySystem.new()
var meteor := AbilityDefinition.new()
var frost := AbilityDefinition.new()


func setup() -> void:
	for event_name: StringName in [
		GameEvents.ABILITY_CAST_STARTED, GameEvents.ABILITY_EXECUTED,
	]:
		EventBus.clear(event_name)
	ResourceManager.clear()

	meteor = AbilityDefinition.new()
	meteor.id = "ability.test.meteor"
	meteor.display_name = "Meteor"
	meteor.cooldown_seconds = 10.0
	meteor.gold_cost = 50
	meteor.cast_delay_seconds = 0.0
	meteor.effect_type = AbilityDefinition.EffectType.AREA_DAMAGE
	meteor.damage = 40
	meteor.radius = 100.0

	frost = AbilityDefinition.new()
	frost.id = "ability.test.frost"
	frost.display_name = "Frost"
	frost.cooldown_seconds = 8.0
	frost.gold_cost = 0
	frost.effect_type = AbilityDefinition.EffectType.FREEZE
	frost.freeze_duration = 2.0
	frost.radius = 120.0

	ResourceManager.register(meteor)
	ResourceManager.register(frost)

	wallet = EconomySystem.new()
	wallet.configure(100)
	registry = EnemyRegistry.new()
	stage(registry)

	abilities = AbilitySystem.new()
	stage(abilities)
	abilities.setup([meteor, frost], wallet, registry)


func teardown() -> void:
	unstage(abilities)
	abilities.free()
	unstage(registry)
	registry.free()
	EventBus.clear(GameEvents.ABILITY_CAST_STARTED)
	EventBus.clear(GameEvents.ABILITY_EXECUTED)
	ResourceManager.clear()


func _spawn_enemy_at(position: Vector2) -> GameEntity:
	var definition := EnemyDefinition.new()
	definition.id = "enemy.ability.dummy"
	definition.display_name = "Dummy"
	definition.max_health = 30
	definition.speed = 100.0
	var route := PathDefinition.new()
	route.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(500, 0)])
	var enemy := EnemyFactory.create(definition, route, null)
	enemy.position = position
	return enemy


func test_cast_requires_armed_and_off_cooldown() -> void:
	assert_false(abilities.try_cast_at(Vector2.ZERO), "nothing armed")
	abilities.arm(meteor)
	assert_true(abilities.try_cast_at(Vector2.ZERO), "cast succeeds")
	abilities.arm(meteor)
	assert_false(abilities.try_cast_at(Vector2.ZERO), "cooldown blocks recast")


func test_gold_cost_charged() -> void:
	abilities.arm(meteor)
	abilities.try_cast_at(Vector2.ZERO)
	assert_eq(50, wallet.gold, "gold cost deducted")


func test_unaffordable_ability_refused() -> void:
	wallet.spend(100)
	abilities.arm(meteor)
	assert_false(abilities.try_cast_at(Vector2.ZERO), "poor player cannot cast")
	assert_eq(0, wallet.gold, "no charge attempted")


func test_area_damage_hits_radius_only() -> void:
	var near := _spawn_enemy_at(Vector2(60, 0))
	var far := _spawn_enemy_at(Vector2(400, 0))
	registry._on_enemy_spawned({"entity": near})
	registry._on_enemy_spawned({"entity": far})

	var executed := [0]
	EventBus.subscribe(GameEvents.ABILITY_EXECUTED, func(p: Dictionary) -> void:
		if int(p.get("hits", 0)) > 0:
			executed[0] += 1)

	abilities.arm(meteor)
	assert_true(abilities.try_cast_at(Vector2.ZERO))
	abilities.advance(0.01)
	assert_eq(1, executed[0], "executed with one hit")

	var near_health: HealthComponent = near.get_component(HealthComponent)
	assert_eq(0, near_health.current_health, "near enemy killed (30hp vs 40dmg)")
	var far_health: HealthComponent = far.get_component(HealthComponent)
	assert_eq(30, far_health.current_health, "far enemy untouched")
	near.free()
	far.free()


func test_freeze_stops_and_restores_movement() -> void:
	var enemy := _spawn_enemy_at(Vector2.ZERO)
	registry._on_enemy_spawned({"entity": enemy})
	var movement: MovementComponent = enemy.get_component(MovementComponent)

	abilities.arm(frost)
	assert_true(abilities.try_cast_at(Vector2.ZERO))
	assert_true(movement.is_frozen(), "frozen on cast")
	movement.advance(1.0)
	assert_eq(Vector2.ZERO, enemy.position, "no movement while frozen")

	abilities.advance(2.5)
	assert_false(movement.is_frozen(), "restored after duration")
	movement.advance(0.5)
	assert_almost_eq(50.0, enemy.position.x, 0.01, "moves again after thaw")
	enemy.free()


func test_cooldowns_tick_down_via_advance() -> void:
	abilities.arm(frost)
	abilities.try_cast_at(Vector2.ZERO)
	assert_almost_eq(8.0, abilities.cooldown_remaining(frost), 0.001, "full cooldown")
	abilities.advance(3.0)
	assert_almost_eq(5.0, abilities.cooldown_remaining(frost), 0.001, "partially cooled")
	abilities.advance(5.0)
	assert_almost_eq(0.0, abilities.cooldown_remaining(frost), 0.001, "ready again")
	assert_false(abilities.is_on_cooldown(frost), "off cooldown flag")
