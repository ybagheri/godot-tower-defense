## Creates runtime enemies from EnemyDefinitions (SPEC-0008).
##
## Factories create, attach, initialize; they never calculate combat or
## manage waves. The factory publishes enemy_spawned: producers announce,
## registries listen.
class_name EnemyFactory
extends RefCounted

static var _counter: int = 0


## Builds an enemy entity. When [param parent] is non-null the entity is
## added to it (which activates it via _ready); pass null to configure
## before parenting.
static func create(definition: EnemyDefinition, path: PathDefinition, parent: Node = null) -> GameEntity:
	if definition == null or path == null:
		push_error("EnemyFactory.create: missing definition or path")
		return null

	_counter += 1
	var entity := GameEntity.new()
	entity.entity_id = definition.id
	entity.name = "enemy_%s_%03d" % [definition.id.replace(".", "_"), _counter]
	entity.add_tag("enemy")
	if definition.flying:
		entity.add_tag("flying")
	if definition.is_boss:
		entity.add_tag("boss")

	var health := HealthComponent.new()
	entity.add_component(health)
	health.configure(definition.max_health)

	var stats := StatsComponent.new()
	entity.add_component(stats)
	stats.apply_enemy_definition(definition)

	var movement := MovementComponent.new()
	entity.add_component(movement)
	movement.setup(path, definition.speed)

	# Spawn ON the route: without this the entity sits at container origin
	# (0,0) until advance() walks it diagonally toward waypoints[1], which
	# read on-device as enemies leaving the path until its first turn.
	entity.position = path.first_waypoint()

	var loot := LootComponent.new()
	entity.add_component(loot)
	loot.configure(definition.reward_gold, definition.damage_to_castle)

	if definition.visual_scene != null:
		var visual := definition.visual_scene.instantiate()
		if visual is Node2D:
			entity.add_child(visual)
		else:
			push_error("EnemyFactory: visual_scene of '%s' has no Node2D root" % definition.id)
			visual.free()

	if parent != null:
		parent.add_child(entity)

	EventBus.publish(GameEvents.ENEMY_SPAWNED,
			{"entity": entity, "enemy_id": definition.id})
	return entity


## Resets the runtime naming counter (used between test runs).
static func reset_counter() -> void:
	_counter = 0
