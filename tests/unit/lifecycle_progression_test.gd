## Tests for enemy cleanup on death and goal arrival (M4 regression fix) and
## progression star recording (SPEC-0011/0012).
extends TestSuite

const LifecycleScript := preload("res://scripts/systems/enemies/enemy_lifecycle_system.gd")
const ProgressionScript := preload("res://scripts/gameplay/progression_tracker.gd")

var lifecycle: Node = null


func setup() -> void:
	EventBus.clear(GameEvents.ENEMY_DIED)
	EventBus.clear(GameEvents.ENEMY_REACHED_GOAL)
	lifecycle = LifecycleScript.new()
	stage(lifecycle)


func teardown() -> void:
	unstage(lifecycle)
	lifecycle.free()
	EventBus.clear(GameEvents.ENEMY_DIED)
	EventBus.clear(GameEvents.ENEMY_REACHED_GOAL)
	save_manager().delete_save()


func _make_enemy() -> GameEntity:
	var definition := EnemyDefinition.new()
	definition.id = "enemy.cleanup.dummy"
	definition.display_name = "Dummy"
	definition.max_health = 5
	var route := PathDefinition.new()
	route.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(50, 0)])
	return EnemyFactory.create(definition, route, null)


func test_dead_enemy_deactivates_then_fades_in_tree() -> void:
	var enemy := _make_enemy()
	stage(enemy)
	# No relay in this suite: publish the game-level death event directly.
	EventBus.publish(GameEvents.ENEMY_DIED, {"entity": enemy})
	assert_true(enemy.state == GameEntity.State.DISABLED, "deactivated on death")
	assert_false(enemy.is_queued_for_deletion(), "fade tween still running")
	unstage(enemy)
	enemy.free()


func test_death_outside_tree_frees_immediately() -> void:
	var enemy := _make_enemy()
	EventBus.publish(GameEvents.ENEMY_DIED, {"entity": enemy})
	assert_false(is_instance_valid(enemy), "no tree -> no fade, freed directly")


func test_goal_arrival_queues_removal() -> void:
	var enemy := _make_enemy()
	stage(enemy)
	EventBus.publish(GameEvents.ENEMY_REACHED_GOAL, {"entity": enemy})
	assert_true(is_instance_valid(enemy), "queued removal still valid this frame")
	assert_true(enemy.is_queued_for_deletion(), "marked for deletion")
	unstage(enemy)
	enemy.free()


func test_stars_thresholds() -> void:
	assert_eq(3, ProgressionScript.stars_for_health_ratio(0.9), "healthy castle")
	assert_eq(3, ProgressionScript.stars_for_health_ratio(0.7), "threshold inclusive")
	assert_eq(2, ProgressionScript.stars_for_health_ratio(0.5), "damaged castle")
	assert_eq(2, ProgressionScript.stars_for_health_ratio(0.35), "threshold inclusive")
	assert_eq(1, ProgressionScript.stars_for_health_ratio(0.1), "barely survived")


func test_progression_records_best_result_and_persists() -> void:
	var tracker: Node = ProgressionScript.new()
	tracker.setup(save_manager())
	save_manager().reset_to_fresh()
	stage(tracker)

	var first: int = tracker.record_stage_result("stage.test", 0.8)
	assert_eq(3, first, "three stars at 80% health")
	var second: int = tracker.record_stage_result("stage.test", 0.2)
	assert_eq(1, second, "worse run returns its own stars")

	var stored: Dictionary = save_manager().get_section("progression")
	assert_eq(3, int(stored.get("stages", {}).get("stage.test", 0)),
			"best result persisted to disk-backed data")
	unstage(tracker)
	tracker.free()
