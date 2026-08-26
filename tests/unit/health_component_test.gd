## Unit tests for HealthComponent behavior (SPEC-0003/0006).
extends TestSuite

var _death_events: Array[Dictionary] = []
var _changes: int = 0

var entity: GameEntity = null
var health: HealthComponent = null


func setup() -> void:
	EventBus.clear(GameEvents.ENTITY_DIED)
	_death_events = []
	_changes = 0
	entity = GameEntity.new()
	health = HealthComponent.new()
	entity.add_component(health)
	health.configure(100)
	EventBus.subscribe(GameEvents.ENTITY_DIED, func(p: Dictionary) -> void:
		_death_events.append(p))


func teardown() -> void:
	EventBus.clear(GameEvents.ENTITY_DIED)
	if is_instance_valid(entity):
		entity.free()


func test_configure_sets_pool() -> void:
	assert_eq(100, health.current_health, "full after configure")
	assert_true(health.is_alive(), "alive")


func test_damage_partial_and_lethal() -> void:
	health.receive_damage(30)
	assert_eq(70, health.current_health, "partial damage applied")
	assert_true(health.is_alive(), "still alive")
	assert_eq(0, _death_events.size(), "no death event yet")

	health.receive_damage(500)
	assert_eq(0, health.current_health, "overkill clamps to zero")
	assert_false(health.is_alive(), "dead")
	assert_eq(1, _death_events.size(), "entity_died published once")


func test_death_event_published_only_once() -> void:
	health.receive_damage(1000)
	health.receive_damage(1000)
	assert_eq(1, _death_events.size(), "second hit does not re-announce death")


func test_heal_caps_at_max() -> void:
	health.receive_damage(50)
	var healed := health.heal(80)
	assert_eq(50, healed, "heal clamped to missing amount")
	assert_eq(100, health.current_health, "back to full")


func test_dead_entity_ignores_damage_and_heal() -> void:
	health.receive_damage(100)
	assert_eq(0, health.receive_damage(10), "corpse takes nothing")
	assert_eq(0, health.heal(10), "corpse not healable without configure")


func test_reconfigure_revives_for_pooling() -> void:
	health.receive_damage(100)
	assert_eq(1, _death_events.size(), "first death announced")
	health.configure(50)
	assert_eq(50, health.current_health, "reset to new max")
	assert_true(health.is_alive(), "alive again")
	health.receive_damage(50)
	assert_eq(2, _death_events.size(), "fresh death cycle announces again")
