## Unit tests for GameEntity + GameComponent composition (SPEC-0002/0003).
extends TestSuite

const StubComponentScript := preload("res://tests/fixtures/stub_component.gd")

var entity: GameEntity = null


func setup() -> void:
	entity = null


func teardown() -> void:
	if is_instance_valid(entity):
		if entity.is_inside_tree():
			unstage(entity)
		entity.free()


func test_programmatic_attachment_runs_setup() -> void:
	entity = GameEntity.new()
	var component := StubComponentScript.new()
	assert_true(entity.add_component(component), "attachment succeeds")
	assert_eq(1, component.setup_calls, "on_setup called once")
	assert_eq(entity, component.get_entity(), "entity back-reference set")


func test_component_lookup_by_script() -> void:
	entity = GameEntity.new()
	var component := StubComponentScript.new()
	entity.add_component(component)
	assert_eq(component, entity.get_component(StubComponentScript), "lookup by script returns instance")
	assert_true(entity.has_component(StubComponentScript), "has_component true")
	assert_null(entity.get_component(GameResource), "missing capability is null")


func test_duplicate_capability_is_refused() -> void:
	entity = GameEntity.new()
	entity.entity_id = "test_entity"
	assert_true(entity.add_component(StubComponentScript.new()), "first attachment ok")
	assert_false(entity.add_component(StubComponentScript.new()), "duplicate refused")


func test_activation_lifecycle_hooks() -> void:
	entity = GameEntity.new()
	var component := StubComponentScript.new()
	entity.add_component(component)
	assert_eq(0, component.activated_calls, "not active while CREATED")
	entity.activate()
	assert_eq(GameEntity.State.ACTIVE, entity.state, "entity ACTIVE")
	assert_eq(1, component.activated_calls, "component activated")
	entity.deactivate()
	assert_eq(GameEntity.State.DISABLED, entity.state, "entity DISABLED")
	assert_eq(1, component.deactivated_calls, "component deactivated")
	entity.activate()
	assert_eq(2, component.activated_calls, "re-activation propagates")


func test_late_attachment_while_active_activates_immediately() -> void:
	entity = GameEntity.new()
	entity.activate()
	var component := StubComponentScript.new()
	entity.add_component(component)
	assert_eq(1, component.setup_calls, "setup ran")
	assert_eq(1, component.activated_calls, "late component activated with entity")


func test_scene_children_auto_register_on_ready() -> void:
	entity = GameEntity.new()
	entity.entity_id = "auto_test"
	var component := StubComponentScript.new()
	entity.add_child(component)
	stage(entity)
	assert_eq(GameEntity.State.ACTIVE, entity.state, "_ready initialized and activated")
	assert_not_null(entity.get_component(StubComponentScript), "child discovered and registered")
	assert_eq(1, component.setup_calls, "scene component set up once")
	assert_eq(1, component.activated_calls, "scene component activated once")


func test_remove_component_frees_it() -> void:
	entity = GameEntity.new()
	var component := StubComponentScript.new()
	entity.add_component(component)
	entity.remove_component(component)
	assert_false(is_instance_valid(component), "component freed by owner")
	assert_false(entity.has_component(StubComponentScript), "capability unregistered")


func test_destroy_tears_down_outside_tree() -> void:
	entity = GameEntity.new()
	var component := StubComponentScript.new()
	entity.add_component(component)
	entity.destroy()
	assert_eq(GameEntity.State.DESTROYED, entity.state, "destroyed state")
	assert_eq(1, component.removed_calls, "on_removed called")
	entity.free()
	assert_false(is_instance_valid(entity), "caller frees torn-down entity")
	entity = null


func test_tags() -> void:
	entity = GameEntity.new()
	entity.add_tag("enemy")
	entity.add_tag("flying")
	entity.add_tag("flying")
	assert_true(entity.has_tag("enemy"), "tag added")
	assert_eq(2, entity.tags.size(), "no duplicates")
	entity.remove_tag("flying")
	assert_false(entity.has_tag("flying"), "tag removed")
	assert_true(entity.has_tag("enemy"), "other tags intact")
