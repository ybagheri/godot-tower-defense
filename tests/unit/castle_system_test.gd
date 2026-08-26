## Tests for CastleSystem arrival damage and destruction (SPEC-0008/0013).
extends TestSuite

var castle := GameEntity.new()
var system := CastleSystem.new()
var events := {}


func setup() -> void:
	for event_name: StringName in [GameEvents.CASTLE_DAMAGED, GameEvents.CASTLE_DESTROYED]:
		EventBus.clear(event_name)
	events = {"damaged": 0, "destroyed": 0, "last_current": -1}
	EventBus.subscribe(GameEvents.CASTLE_DAMAGED, func(p: Dictionary) -> void:
		events.damaged += 1
		events.last_current = int(p.get("current", -1)))
	EventBus.subscribe(GameEvents.CASTLE_DESTROYED, func(_p: Dictionary) -> void:
		events.destroyed += 1)

	castle = CastleSceneScript.instantiate()
	stage(castle)
	var health := castle.get_component(HealthComponent) as HealthComponent
	health.configure(10)
	system = CastleSystem.new()
	system.setup(castle)
	stage(system)


func teardown() -> void:
	unstage(system)
	system.free()
	unstage(castle)
	if is_instance_valid(castle):
		castle.free()
	for event_name: StringName in [GameEvents.CASTLE_DAMAGED, GameEvents.CASTLE_DESTROYED]:
		EventBus.clear(event_name)


const CastleSceneScript := preload("res://scenes/shared/castle.tscn")


func _arrival(damage_to_castle: int) -> void:
	var enemy := EnemyFactory.create(_goblin_with_damage(damage_to_castle), _route(), null)
	EventBus.publish(GameEvents.ENEMY_REACHED_GOAL, {"entity": enemy})
	enemy.free()


func _goblin_with_damage(damage: int) -> EnemyDefinition:
	var definition := EnemyDefinition.new()
	definition.id = "enemy.test.ram"
	definition.display_name = "Ram"
	definition.max_health = 5
	definition.damage_to_castle = damage
	return definition


func _route() -> PathDefinition:
	var path := PathDefinition.new()
	path.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(10, 0)])
	return path


func test_arrival_applies_loot_damage() -> void:
	_arrival(3)
	assert_eq(7, system.current_health(), "castle took 3 damage")
	assert_eq(1, events.damaged, "castle_damaged published")
	assert_eq(7, events.last_current, "payload carries remaining health")
	assert_eq(0, events.destroyed, "still standing")


func test_destruction_announced_once() -> void:
	_arrival(4)
	_arrival(4)
	_arrival(4)
	assert_true(system.is_destroyed(), "castle down at 10 vs 12 incoming")
	assert_eq(1, events.destroyed, "destroyed event exactly once")
	assert_eq(3, events.damaged, "every damaging arrival counts, incl. killing blow")


func test_missing_castle_is_safe() -> void:
	var empty_system := CastleSystem.new()
	stage(empty_system)
	_arrival(5)
	assert_eq(0, empty_system.current_health(), "no health means zero")
	assert_true(empty_system.is_destroyed(), "treated as destroyed")
	unstage(empty_system)
	empty_system.free()
