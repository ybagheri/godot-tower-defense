## Selects attack targets from a candidate provider (SPEC-0007 targeting).
##
## The component never searches the scene tree itself: the battle wiring
## injects a provider Callable (usually EnemyRegistry.get_enemies), keeping
## engine-side components free of game knowledge.
class_name TargetingComponent
extends GameComponent

enum Priority { FIRST, CLOSEST, STRONGEST, LOWEST_HEALTH }

@export var priority: Priority = Priority.FIRST
@export var range_px: float = 300.0
## Ground towers may be unable to hit flying enemies; data decides per tower.
@export var can_target_flying: bool = true

## Callable returning Array[GameEntity]; injected by battle setup.
var candidate_provider: Callable = Callable()


## Returns the best living candidate in range according to priority,
## or null when nothing qualifies.
func select_target() -> GameEntity:
	if candidate_provider.is_null() or not candidate_provider.is_valid():
		return null
	var owner_entity := get_entity()
	if owner_entity == null:
		return null
	var candidates: Array = candidate_provider.call()

	var best: GameEntity = null
	var best_score := INF
	for candidate: GameEntity in candidates:
		if not _is_valid_candidate(candidate):
			continue
		var distance := owner_entity.position.distance_to(candidate.position)
		if distance > range_px:
			continue
		var score := _score(candidate, distance)
		if best == null or score < best_score:
			best = candidate
			best_score = score
	return best


func _is_valid_candidate(candidate: GameEntity) -> bool:
	if not is_instance_valid(candidate):
		return false
	if candidate.has_tag("flying") and not can_target_flying:
		return false
	var health: HealthComponent = candidate.get_component(HealthComponent)
	return health != null and health.is_alive()


## Lower score wins.
func _score(candidate: GameEntity, distance: float) -> float:
	match priority:
		Priority.FIRST:
			var movement: MovementComponent = candidate.get_component(MovementComponent)
			return movement.distance_remaining() if movement != null else distance
		Priority.CLOSEST:
			return distance
		Priority.STRONGEST:
			var health: HealthComponent = candidate.get_component(HealthComponent)
			return -float(health.max_health)
		Priority.LOWEST_HEALTH:
			var health: HealthComponent = candidate.get_component(HealthComponent)
			return float(health.current_health)
	return distance
