## Validates shipped content resources and battle scene wiring (SPEC-0001).
##
## These tests catch broken .tres references, invalid definitions, route key
## mismatches between spawn groups and the path catalog, and missing scene
## bindings before anything reaches a device.
extends TestSuite

const STAGE := preload("res://resources/stages/stage_001_test_range.tres")
const GOBLIN := preload("res://resources/enemies/enemy_goblin_basic.tres")
const WISP := preload("res://resources/enemies/enemy_wisp_fast.tres")
const OGRE := preload("res://resources/enemies/enemy_ogre_boss.tres")
const ARCHER := preload("res://resources/towers/tower_archer_basic.tres")
const BALANCE := preload("res://resources/balance/balance_default.tres")
const BATTLE_SCENE := preload("res://scenes/game/battle.tscn")


func test_all_definitions_validate_clean() -> void:
	for definition: GameResource in [GOBLIN, WISP, OGRE, ARCHER, BALANCE, STAGE]:
		var report: Dictionary = definition.validate()
		assert_true((report.errors as PackedStringArray).is_empty(),
				"%s must validate clean but had %s" % [definition.id,
				", ".join(report.errors)])


func test_stage_route_keys_match_spawn_groups() -> void:
	for wave: WaveDefinition in STAGE.waves:
		for group: SpawnGroupDefinition in wave.spawn_groups:
			assert_not_null(STAGE.get_route(group.path_id),
					"%s group '%s' references unknown route" % [wave.id, group.enemy_id])
			assert_true(WISP.id == group.enemy_id or GOBLIN.id == group.enemy_id
					or OGRE.id == group.enemy_id,
					"group enemy id '%s' exists in catalog" % group.enemy_id)


func test_wave_numbers_are_ordered() -> void:
	var previous := 0
	for wave: WaveDefinition in STAGE.waves:
		assert_eq(previous + 1, wave.wave_number, "waves numbered sequentially")
		previous = wave.wave_number


func test_archer_upgrade_chain_sanity() -> void:
	assert_false(ARCHER.upgrades.is_empty(), "archer has upgrade path")
	var previous_cost := ARCHER.cost
	for upgrade: TowerUpgradeDefinition in ARCHER.upgrades:
		assert_true(upgrade.cost > 0, "upgrade cost positive")
		previous_cost = upgrade.cost


func test_battle_scene_bindings_resolve() -> void:
	var scene := BATTLE_SCENE.instantiate()
	# Staging runs _ready synchronously: full wiring is exercised without
	# needing to wait a frame.
	stage(scene)

	var controller := scene as BattleController
	assert_not_null(controller, "root carries BattleController")
	if controller != null:
		assert_not_null(controller.stage, "stage resource bound")
		assert_eq(1, controller.tower_catalog.size(), "one tower in catalog")
		assert_eq(3, controller.enemy_catalog.size(), "three enemies registered")
		assert_not_null(controller.castle_entity, "castle bound from map")
		assert_not_null(controller.entities_container, "entities container bound")
		assert_true(ResourceManager.has(STAGE.id), "stage registered for systems")
		assert_true(controller.waves.state != WaveSystem.State.IDLE, "battle started")

	unstage(scene)
	scene.free()
	EventBus.clear_all()
