## Validation tests for enemy/tower/wave/stage/path definitions.
extends TestSuite


func _goblin() -> EnemyDefinition:
	var definition := EnemyDefinition.new()
	definition.id = "enemy.goblin.basic"
	definition.display_name = "Goblin"
	return definition


func test_enemy_definition_defaults_valid() -> void:
	assert_true((_goblin().validate().errors as PackedStringArray).is_empty(),
			"defaults satisfy rules")


func test_enemy_rejects_bad_stats() -> void:
	var definition := _goblin()
	definition.max_health = 0
	var report: Dictionary = definition.validate()
	assert_true((report.errors as PackedStringArray).size() >= 1, "zero health rejected")

	definition = _goblin()
	definition.fire_resistance = 1.5
	report = definition.validate()
	assert_true((report.errors as PackedStringArray).size() == 1, "out-of-range resistance rejected")


func test_enemy_resistance_lookup() -> void:
	var definition := _goblin()
	definition.magic_resistance = 0.25
	definition.poison_resistance = 0.75
	assert_almost_eq(0.25, definition.resistance_for(DamageTypes.Type.MAGIC), 0.0001, "magic")
	assert_almost_eq(0.75, definition.resistance_for(DamageTypes.Type.POISON), 0.0001, "poison")
	assert_almost_eq(0.0, definition.resistance_for(DamageTypes.Type.PHYSICAL), 0.0001,
			"physical uses armor instead")


func _archer() -> TowerDefinition:
	var definition := TowerDefinition.new()
	definition.id = "tower.arrow.basic"
	definition.display_name = "Archer Tower"
	return definition


func test_tower_definition_defaults_valid() -> void:
	assert_true((_archer().validate().errors as PackedStringArray).is_empty(), "defaults valid")


func test_tower_rejects_invalid_numbers() -> void:
	var definition := _archer()
	definition.attack_speed = 0
	assert_true((definition.validate().errors as PackedStringArray).size() >= 1, "speed>0")

	definition = _archer()
	definition.critical_chance = 2.0
	assert_true((definition.validate().errors as PackedStringArray).size() >= 1, "crit range")

	definition = _archer()
	definition.uses_projectiles = true
	definition.projectile_speed = 0
	assert_true((definition.validate().errors as PackedStringArray).size() >= 1, "proj speed")


func test_path_definition_rules() -> void:
	var path := PathDefinition.new()
	path.id = "stage001.main"
	assert_true((path.validate().errors as PackedStringArray).size() >= 1, "needs 2 waypoints")
	path.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(100, 0), Vector2(100, 50)])
	assert_true((path.validate().errors as PackedStringArray).is_empty(), "valid route")
	assert_eq(Vector2(100, 50), path.destination(), "last waypoint is destination")
	assert_almost_eq(150.0, path.total_length(), 0.001, "polyline length")


func _wave_with_group(group: SpawnGroupDefinition) -> WaveDefinition:
	var wave := WaveDefinition.new()
	wave.id = "wave.test"
	wave.spawn_groups = [group]
	return wave


func test_wave_rejects_invalid_spawn_groups() -> void:
	var group := SpawnGroupDefinition.new()
	group.enemy_id = ""
	group.count = 0
	group.path_id = ""
	var errors: PackedStringArray = _wave_with_group(group).validate().errors
	assert_true(errors.size() >= 3, "enemy_id/count/path_id each reported")

	group = SpawnGroupDefinition.new()
	group.enemy_id = "enemy.goblin.basic"
	group.count = 5
	group.path_id = "main"
	assert_true((_wave_with_group(group).validate().errors as PackedStringArray).is_empty(),
			"valid group passes")


func test_stage_validation_and_path_lookup() -> void:
	var stage := StageDefinition.new()
	stage.id = "stage.test"
	assert_true((stage.validate().errors as PackedStringArray).size() >= 1, "no waves rejected")

	var main := PathDefinition.new()
	main.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(10, 0)])
	stage.paths = {"main": main}
	stage.waves = [_wave_with_group(SpawnGroupDefinition.new())]
	# The lone group above is invalid; expect its error plus nothing else new.
	var errors: PackedStringArray = stage.validate().errors
	assert_true(errors.size() >= 1, "invalid inner wave surfaces through stage")

	stage.waves = [_wave_with_group(_valid_group())]
	assert_true((stage.validate().errors as PackedStringArray).is_empty(), "fully valid stage")
	assert_eq(main, stage.get_route("main"), "path lookup works")
	assert_null(stage.get_route("missing"), "unknown path null")


func _valid_group() -> SpawnGroupDefinition:
	var group := SpawnGroupDefinition.new()
	group.enemy_id = "enemy.goblin.basic"
	group.count = 3
	group.path_id = "main"
	return group
