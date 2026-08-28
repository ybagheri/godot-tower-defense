## Validates shipped content resources and battle scene wiring (SPEC-0001).
##
## These tests catch broken .tres references, invalid definitions, route key
## mismatches between spawn groups and the path catalog, and missing scene
## bindings before anything reaches a device.
extends TestSuite

const STAGE := preload("res://resources/stages/stage_001_test_range.tres")
const STAGES: Array[StageDefinition] = [
	preload("res://resources/stages/stage_001_test_range.tres"),
	preload("res://resources/stages/stage_002_twin_roads.tres"),
	preload("res://resources/stages/stage_003_ironwood_pass.tres"),
	preload("res://resources/stages/stage_004_broken_crossroads.tres"),
	preload("res://resources/stages/stage_005_warlords_gate.tres"),
]
const GOBLIN := preload("res://resources/enemies/enemy_goblin_basic.tres")
const WISP := preload("res://resources/enemies/enemy_wisp_fast.tres")
const KNIGHT := preload("res://resources/enemies/enemy_knight_elite.tres")
const OGRE := preload("res://resources/enemies/enemy_ogre_boss.tres")
const ARCHER := preload("res://resources/towers/tower_archer_basic.tres")
const MAGE := preload("res://resources/towers/tower_mage_basic.tres")
const CANNON := preload("res://resources/towers/tower_cannon_basic.tres")
const METEOR := preload("res://resources/abilities/ability_meteor_strike.tres")
const FROST := preload("res://resources/abilities/ability_frost_grasp.tres")
const BALANCE := preload("res://resources/balance/balance_default.tres")
const BATTLE_SCENE := preload("res://scenes/game/battle.tscn")


func test_all_definitions_validate_clean() -> void:
	for definition: GameResource in [GOBLIN, WISP, KNIGHT, OGRE, ARCHER, MAGE,
			CANNON, METEOR, FROST, BALANCE, STAGE]:
		var report: Dictionary = definition.validate()
		assert_true((report.errors as PackedStringArray).is_empty(),
				"%s must validate clean but had %s" % [definition.id,
				", ".join(report.errors)])


func test_stage_route_keys_match_spawn_groups() -> void:
	var known_enemies: Array[String] = [WISP.id, GOBLIN.id, KNIGHT.id, OGRE.id]
	for wave: WaveDefinition in STAGE.waves:
		for group: SpawnGroupDefinition in wave.spawn_groups:
			assert_not_null(STAGE.get_route(group.path_id),
					"%s group '%s' references unknown route" % [wave.id, group.enemy_id])
			assert_true(group.enemy_id in known_enemies,
					"group enemy id '%s' exists in catalog" % group.enemy_id)


## Route catalogs must be EXTERNAL .tres files under resources/paths/
## (SPEC-0016) - embedded PathDefinition sub-resources are a migration bug.
func test_route_catalogs_are_external_resources() -> void:
	for stage_res: StageDefinition in STAGES:
		assert_false(stage_res.paths.is_empty(),
				"%s ships a non-empty route catalog" % stage_res.id)
		for route_key: String in stage_res.paths.keys():
			var route: PathDefinition = stage_res.paths[route_key] as PathDefinition
			assert_not_null(route,
					"%s paths['%s'] resolves a PathDefinition" % [stage_res.id, route_key])
			if route != null:
				assert_true(route.resource_path.begins_with("res://resources/paths/"),
						"%s route '%s' lives in the external catalog (got '%s')"
								% [stage_res.id, route.id, route.resource_path])
				assert_eq(route_key, route.id, "catalog key matches route id")


## Every Line2D in a shipped map is bound to its catalog route via the
## route_id meta, covers every catalog key exactly once, and draws exactly
## that route's waypoints (SPEC-0016).
func test_map_line2ds_match_route_catalog_via_route_id_meta() -> void:
	for stage_res: StageDefinition in STAGES:
		if stage_res.map_scene == null:
			continue
		var map: Node = (stage_res.map_scene as PackedScene).instantiate()
		var seen := {}
		for child: Node in map.get_children():
			if not (child is Line2D):
				continue
			assert_true(child.has_meta(&"route_id"),
					"%s map %s carries route_id meta" % [stage_res.id, child.name])
			if not child.has_meta(&"route_id"):
				continue
			var route_key := String(child.get_meta(&"route_id"))
			var route: PathDefinition = stage_res.get_route(route_key)
			assert_not_null(route,
					"%s map %s meta resolves catalog route '%s'"
							% [stage_res.id, child.name, route_key])
			if route == null:
				continue
			assert_false(seen.has(route_key),
					"%s route '%s' drawn exactly once" % [stage_res.id, route_key])
			seen[route_key] = true
			assert_eq(route.waypoints, (child as Line2D).points,
					"%s map %s points equal route '%s' waypoints"
							% [stage_res.id, child.name, route_key])
		for route_key: String in stage_res.paths.keys():
			assert_true(seen.has(route_key),
					"%s route '%s' has a matching Line2D in its map" % [stage_res.id, route_key])
		map.free()


func test_wave_numbers_are_ordered() -> void:
	var previous := 0
	for wave: WaveDefinition in STAGE.waves:
		assert_eq(previous + 1, wave.wave_number, "waves numbered sequentially")
		previous = wave.wave_number


func test_archer_upgrade_chain_sanity() -> void:
	assert_false(ARCHER.upgrades.is_empty(), "archer has upgrade path")
	for tower: TowerDefinition in [ARCHER, MAGE, CANNON]:
		var previous_cost := tower.cost
		for upgrade: TowerUpgradeDefinition in tower.upgrades:
			assert_true(upgrade.cost > previous_cost * 0.5, "upgrade cost sane")
			previous_cost = upgrade.cost


func test_battle_scene_bindings_resolve() -> void:
	var scene := BATTLE_SCENE.instantiate()
	stage(scene)

	var controller := scene as BattleController
	assert_not_null(controller, "root carries BattleController")
	if controller != null:
		assert_not_null(controller.stage, "stage resource bound")
		assert_eq(3, controller.tower_catalog.size(), "three towers in catalog")
		assert_eq(4, controller.enemy_catalog.size(), "four enemies registered")
		assert_eq(2, controller.ability_system().definitions.size(),
				"two abilities available")
		assert_not_null(controller.castle_entity, "castle bound from map")
		assert_not_null(controller.entities_container, "entities container bound")
		assert_true(ResourceManager.has(STAGE.id), "stage registered for systems")
		assert_true(controller.waves.state != WaveSystem.State.IDLE, "battle started")
		assert_false(controller.is_build_armed(), "build mode starts disarmed")
		controller.arm_building(controller.tower_catalog[0])
		assert_false(controller.placement_result_for(Vector2(200, 120)).ok,
				"tile ON the route rejected by placement check")
		assert_true(controller.placement_result_for(Vector2(200, 300)).ok,
				"open ground accepted (affordable, clear)")
		controller.cancel_building()


	unstage(scene)
	scene.free()
	EventBus.clear_all()
