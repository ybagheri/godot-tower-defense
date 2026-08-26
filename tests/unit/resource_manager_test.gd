## Unit tests for the ResourceManager registry (SPEC-0001).
extends TestSuite


class FixtureDefinition extends GameResource:
	@export var max_health: int = 100


func setup() -> void:
	resource_manager().clear()


func teardown() -> void:
	resource_manager().clear()


func _make_definition(resource_id: String, display_name: String) -> FixtureDefinition:
	var definition := FixtureDefinition.new()
	definition.id = resource_id
	definition.display_name = display_name
	return definition


func test_register_and_retrieve() -> void:
	var manager := resource_manager()
	var definition := _make_definition("enemy.goblin.basic", "Goblin")
	assert_true(manager.register(definition), "valid resource registers")
	assert_true(manager.has("enemy.goblin.basic"), "id present")
	assert_eq(definition, manager.get_by_id("enemy.goblin.basic"), "same instance returned")


func test_duplicate_id_is_rejected() -> void:
	var manager := resource_manager()
	manager.register(_make_definition("tower.arrow.basic", "First"))
	var duplicate := _make_definition("tower.arrow.basic", "Second")
	assert_false(manager.register(duplicate), "duplicate refused")
	assert_eq("First", (manager.get_by_id("tower.arrow.basic") as GameResource).display_name,
			"original registration kept")


func test_invalid_resource_is_refused() -> void:
	var manager := resource_manager()
	var invalid := FixtureDefinition.new()
	invalid.id = "Not Valid"
	assert_false(manager.register(invalid), "invalid id refuses registration")
	assert_false(manager.has("Not Valid"), "nothing registered under invalid id")


func test_null_resource_is_refused() -> void:
	assert_false(resource_manager().register(null), "null is rejected")


func test_get_unknown_returns_null() -> void:
	assert_null(resource_manager().get_by_id("does.not.exist"), "unknown id is null")


func test_require_unknown_logs_error() -> void:
	assert_null(resource_manager().require("does.not.exist"), "unknown id is null even via require")


func test_category_filtering() -> void:
	var manager := resource_manager()
	manager.register(_make_definition("enemy.goblin.basic", "Goblin"))
	manager.register(_make_definition("enemy.orc.brute", "Orc"))
	manager.register(_make_definition("tower.arrow.basic", "Archer Tower"))
	var enemies: Array[GameResource] = manager.get_category("enemy")
	assert_eq(2, enemies.size(), "two enemies registered")
	var towers: Array[GameResource] = manager.get_category("tower")
	assert_eq(1, towers.size(), "one tower registered")


func test_clear_empties_registry() -> void:
	var manager := resource_manager()
	manager.register(_make_definition("stage.001", "Stage One"))
	manager.clear()
	assert_eq(0, manager.count(), "registry empty after clear")
