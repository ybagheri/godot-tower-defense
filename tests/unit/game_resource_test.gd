## Unit tests for GameResource validation (SPEC-0001).
extends TestSuite


class MinimalDefinition extends GameResource:
	pass


class WeaponDefinition extends GameResource:
	@export var damage: int = 0

	func validate() -> Dictionary:
		var report := super.validate()
		var errors: PackedStringArray = report.errors
		if damage < 0:
			errors.append("damage must be >= 0")
		return report


func test_missing_id_is_rejected() -> void:
	var definition := MinimalDefinition.new()
	var report: Dictionary = definition.validate()
	assert_false((report.errors as PackedStringArray).is_empty(), "missing id produces an error")


func test_valid_id_passes() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "enemy.goblin.basic"
	definition.display_name = "Goblin"
	var report: Dictionary = definition.validate()
	assert_true((report.errors as PackedStringArray).is_empty(), "no errors for valid definition")
	assert_true((report.warnings as PackedStringArray).is_empty(), "display_name suppresses warning")


func test_uppercase_id_is_rejected() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "Enemy.Goblin"
	var report: Dictionary = definition.validate()
	assert_false((report.errors as PackedStringArray).is_empty(), "ids must be lowercase")


func test_id_with_space_is_rejected() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "enemy goblin basic"
	var report: Dictionary = definition.validate()
	assert_false((report.errors as PackedStringArray).is_empty(), "ids must not contain spaces")


func test_invalid_version_is_rejected() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "tower.arrow.basic"
	definition.version = 0
	var report: Dictionary = definition.validate()
	assert_false((report.errors as PackedStringArray).is_empty(), "version must be >= 1")


func test_missing_display_fields_warns() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "ability.fireball.basic"
	var report: Dictionary = definition.validate()
	assert_eq(1, (report.warnings as PackedStringArray).size(), "one warning about display fields")


func test_subclass_validation_merges_base_rules() -> void:
	var weapon := WeaponDefinition.new()
	weapon.id = "weapon.test.axe"
	weapon.damage = -5
	var report: Dictionary = weapon.validate()
	var errors: PackedStringArray = report.errors
	assert_eq(1, errors.size(), "only subclass error (base rules satisfied)")
	assert_true(errors[0].contains("damage"), "subclass error present")


func test_category_extraction() -> void:
	var definition := MinimalDefinition.new()
	definition.id = "enemy.orc.brute"
	assert_eq("enemy", definition.category(), "category is first segment")
