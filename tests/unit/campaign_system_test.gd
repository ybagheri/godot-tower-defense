## Tests for campaign model, unlock gating, SceneManager handoff and the
## menu scene (SPEC-0011 progression shell).
extends TestSuite

const CampaignScript := preload("res://scripts/resources/campaign_definition.gd")
const CAMPAIGN := preload("res://resources/campaigns/campaign_001.tres")
const STAGE_002 := preload("res://resources/stages/stage_002_twin_roads.tres")
const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")


func setup() -> void:
	save_manager().reset_to_fresh()


func teardown() -> void:
	save_manager().delete_save()
	EventBus.clear_all()


func _stars(stages: Dictionary) -> Dictionary:
	return stages


func test_campaign_ships_two_stages_in_order() -> void:
	assert_true((CAMPAIGN.validate().errors as PackedStringArray).is_empty(),
			"shipped campaign validates clean")
	assert_eq(2, CAMPAIGN.entries.size(), "two stage entries")
	var first: StageDefinition = CAMPAIGN.entries[0].stage
	var second: StageDefinition = CAMPAIGN.entries[1].stage
	assert_eq("stage.001.test_range", first.id, "entry order stable")
	assert_eq("stage.002.twin_roads", second.id, "entry order stable")
	assert_not_null(first.map_scene, "stage 1 ships a map")
	assert_not_null(second.map_scene, "stage 2 ships a map")


func test_stage002_multi_route_content() -> void:
	var report: Dictionary = STAGE_002.validate()
	assert_true((report.errors as PackedStringArray).is_empty(),
			"stage 002 valid: %s" % ", ".join(report.errors))
	assert_eq(2, STAGE_002.paths.size(), "two routes defined")
	for wave: WaveDefinition in STAGE_002.waves:
		for group: SpawnGroupDefinition in wave.spawn_groups:
			assert_not_null(STAGE_002.get_route(group.path_id),
					"route '%s' resolves" % group.path_id)


func test_unlock_gating_is_sequential() -> void:
	var fresh := {}
	assert_true(CampaignScript.is_entry_unlocked(CAMPAIGN, 0, fresh),
			"first stage always unlocked")
	assert_false(CampaignScript.is_entry_unlocked(CAMPAIGN, 1, fresh),
			"second locked on fresh save")

	var one_star := {"stage.001.test_range": 1}
	assert_true(CampaignScript.is_entry_unlocked(CAMPAIGN, 1, one_star),
			"completing stage 1 opens stage 2")

	var out_of_range := CampaignScript.is_entry_unlocked(CAMPAIGN, 5, one_star)
	assert_false(out_of_range, "out-of-range index never unlocked")


func test_progression_recording_feeds_the_gate() -> void:
	var tracker := ProgressionTracker.new()
	tracker.setup(save_manager())
	stage(tracker)
	tracker.castle_ratio_provider = func() -> float: return 1.0
	EventBus.publish(GameEvents.STAGE_COMPLETED, {"stage_id": "stage.001.test_range"})

	var stars: Dictionary = save_manager().get_section("progression").get("stages", {})
	assert_true(int(stars.get("stage.001.test_range", 0)) >= 1,
			"completion recorded through events")
	assert_true(CampaignScript.is_entry_unlocked(CAMPAIGN, 1, stars),
			"gate opens after event-driven completion")
	unstage(tracker)
	tracker.free()


func test_scene_manager_hands_off_stage_path() -> void:
	var router := autoload("SceneManager")
	router.queue_stage("res://resources/stages/stage_002_twin_roads.tres")
	var pending: String = router.consume_pending_stage()
	assert_eq("res://resources/stages/stage_002_twin_roads.tres", pending,
			"queued path delivered once")
	assert_eq("", router.consume_pending_stage(), "consumption clears the queue")


func test_battle_loads_queued_stage_and_dynamic_map() -> void:
	var router := autoload("SceneManager")
	router.queue_stage("res://resources/stages/stage_002_twin_roads.tres")

	var battle: BattleController = (load("res://scenes/game/battle.tscn") as PackedScene).instantiate()
	stage(battle)

	assert_eq("stage.002.twin_roads", battle.stage.id,
			"queued campaign selection overrides default export")
	assert_not_null(battle.castle_entity, "castle resolved from dynamic map")
	assert_eq("TwinRoads", battle.castle_entity.get_parent().name,
			"castle belongs to the twin roads map")
	assert_true(battle.building.protected_routes.size() == 2,
			"both routes registered for placement checks")
	assert_true(battle.waves.state != WaveSystem.State.IDLE, "battle running")

	unstage(battle)
	battle.free()
	router.queue_stage("")


func test_menu_builds_buttons_with_fresh_save_locks() -> void:
	var menu := MENU_SCENE.instantiate()
	stage(menu)
	var list: VBoxContainer = menu.get_node("%StageList")
	assert_eq(2, list.get_child_count(), "one button per campaign entry")
	var second_button: Button = list.get_child(1)
	assert_true(second_button.disabled, "stage 2 disabled on fresh save")
	assert_true(second_button.text.contains(tr("UI_LOCKED")), "locked label shown")
	unstage(menu)
	menu.free()
