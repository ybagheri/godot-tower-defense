## Moves the owning entity along a PathDefinition (SPEC-0009).
##
## Path tells WHERE, movement tells HOW: this component walks waypoints at
## its speed and announces arrival. Position math uses local entity position,
## assuming entities live under an untransformed battle container.
class_name MovementComponent
extends GameComponent

signal destination_reached

var speed: float = 80.0
## Multiplicative modifier reserved for slow effects.
var speed_multiplier: float = 1.0
## Hard stop used by freeze effects; overrides the multiplier.
var frozen: bool = false

var current_path: PathDefinition = null

var _waypoint_index: int = 0
var _finished: bool = false
var _running: bool = false


func set_frozen(value: bool) -> void:
	frozen = value


func is_frozen() -> bool:
	return frozen


## Assigns the route; resets progress so pooled entities restart cleanly.
func setup(path: PathDefinition, move_speed: float) -> void:
	current_path = path
	speed = move_speed
	_waypoint_index = 1
	_finished = path == null or path.waypoint_count() < 2


func is_moving() -> bool:
	return current_path != null and not _finished


## Remaining distance along the route; 0 when finished. Used by FIRST
## targeting priority (furthest along = smallest remaining distance).
func distance_remaining() -> float:
	if current_path == null or _finished:
		return 0.0
	var entity := get_entity()
	var cursor := entity.position if entity != null else current_path.first_waypoint()
	var total := cursor.distance_to(current_path.waypoints[_waypoint_index])
	for i: int in range(_waypoint_index + 1, current_path.waypoint_count()):
		total += current_path.waypoints[i - 1].distance_to(current_path.waypoints[i])
	return total


## Advances movement by [param delta] seconds. Runs regardless of activation
## so factories/tests can simulate deterministically; _process forwards only
## while the owning entity is active.
func advance(delta: float) -> void:
	if _finished or delta <= 0.0 or current_path == null:
		return
	var entity := get_entity()
	if entity == null:
		return
	var step := speed * speed_multiplier * delta
	if frozen:
		step = 0.0
	while step > 0.0 and not _finished:
		var target := current_path.waypoints[_waypoint_index]
		var to_target := target - entity.position
		var dist := to_target.length()
		if dist <= step:
			entity.position = target
			step -= dist
			_waypoint_index += 1
			if _waypoint_index >= current_path.waypoint_count():
				_finish_route()
		else:
			entity.position += to_target.normalized() * step
			step = 0.0


func _finish_route() -> void:
	_finished = true
	destination_reached.emit()
	EventBus.publish(GameEvents.ENTITY_REACHED_DESTINATION, {"entity": get_entity()})


func _process(delta: float) -> void:
	if _running:
		advance(delta)


func on_activated() -> void:
	_running = true
	set_process(true)


func on_deactivated() -> void:
	_running = false
	set_process(false)


func on_removed() -> void:
	set_process(false)
