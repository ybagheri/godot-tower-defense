## Unit tests for MovementComponent waypoint following (SPEC-0009).
extends TestSuite

var entity: GameEntity = null
var movement: MovementComponent = null
var path := PathDefinition.new()
var arrivals: int = 0


func setup() -> void:
	EventBus.clear(GameEvents.ENTITY_REACHED_DESTINATION)
	arrivals = 0
	path = PathDefinition.new()
	path.waypoints = PackedVector2Array([
		Vector2(0, 0), Vector2(100, 0), Vector2(100, 100),
	])
	entity = GameEntity.new()
	movement = MovementComponent.new()
	entity.add_component(movement)
	movement.setup(path, 100.0)
	movement.destination_reached.connect(func() -> void:
		arrivals += 1)


func teardown() -> void:
	EventBus.clear(GameEvents.ENTITY_REACHED_DESTINATION)
	if is_instance_valid(entity):
		entity.free()


func test_moves_towards_first_segment() -> void:
	movement.advance(1.0)
	assert_eq(Vector2(100, 0), entity.position, "one second at 100px/s completes leg one")


func test_full_route_arrives_and_publishes_event() -> void:
	var reached_events := [0]
	EventBus.subscribe(GameEvents.ENTITY_REACHED_DESTINATION, func(_p: Dictionary) -> void:
		reached_events[0] += 1)
	movement.advance(1.0)
	movement.advance(1.5)
	assert_eq(Vector2(100, 100), entity.position, "destination reached")
	assert_eq(1, arrivals, "local signal emitted once")
	assert_eq(1, reached_events[0], "global event published once")
	assert_false(movement.is_moving(), "movement finished")


func test_advance_beyond_destination_is_noop() -> void:
	movement.advance(10.0)
	var final_position := entity.position
	movement.advance(10.0)
	assert_eq(final_position, entity.position, "no drift after arrival")
	assert_eq(1, arrivals, "no duplicate arrival signal")


func test_speed_multiplier_scales_step() -> void:
	movement.speed_multiplier = 0.5
	movement.advance(1.0)
	assert_eq(Vector2(50, 0), entity.position, "half speed halves distance")


func test_distance_remaining_decreases_along_route() -> void:
	assert_almost_eq(200.0, movement.distance_remaining(), 0.01, "full route remaining")
	movement.advance(1.0)
	assert_almost_eq(100.0, movement.distance_remaining(), 0.01, "second leg remaining")
	movement.advance(2.0)
	assert_almost_eq(0.0, movement.distance_remaining(), 0.01, "zero at destination")


func test_setup_resets_for_pooled_reuse() -> void:
	movement.advance(10.0)
	movement.setup(path, 100.0)
	assert_almost_eq(200.0, movement.distance_remaining(), 0.01, "route restarted")
	assert_true(movement.is_moving(), "moving again")
