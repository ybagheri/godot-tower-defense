## Creates runtime towers from TowerDefinitions (SPEC-0007).
##
## Placement validation and payment belong to future building/economy flows;
## this factory only assembles a configured combat entity.
class_name TowerFactory
extends RefCounted

static var _counter: int = 0


## Builds a tower at [param position]. The candidate provider Callable is
## stored on its TargetingComponent (battle wiring injects EnemyRegistry).
static func create(definition: TowerDefinition, position: Vector2,
		candidate_provider: Callable, parent: Node = null) -> GameEntity:
	if definition == null:
		push_error("TowerFactory.create: missing definition")
		return null

	_counter += 1
	var entity := GameEntity.new()
	entity.entity_id = definition.id
	entity.name = "tower_%s_%03d" % [definition.id.replace(".", "_"), _counter]
	entity.add_tag("tower")
	entity.position = position

	var targeting := TargetingComponent.new()
	entity.add_component(targeting)
	targeting.range_px = definition.attack_range
	targeting.priority = definition.targeting_priority
	targeting.candidate_provider = candidate_provider

	var attack := AttackComponent.new()
	entity.add_component(attack)
	attack.configure_from_definition(definition)

	if parent != null:
		parent.add_child(entity)

	EventBus.publish(GameEvents.TOWER_BUILT,
			{"entity": entity, "tower_id": definition.id})
	return entity


static func reset_counter() -> void:
	_counter = 0
