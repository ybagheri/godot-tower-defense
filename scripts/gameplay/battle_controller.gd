## Battle orchestrator: composes all systems into one playable stage.
##
## This is the single place allowed to know every subsystem; it wires them,
## exposes player intents to the HUD, and decides victory/defeat. Gameplay
## rules themselves stay inside the systems.
class_name BattleController
extends Node2D

signal selection_changed(tower: GameEntity)
signal build_mode_changed(armed: bool)
signal battle_ended(victory: bool)

@export var stage: StageDefinition
## Towers offered in the build bar; also registered into ResourceManager.
@export var tower_catalog: Array[TowerDefinition]
## Enemies used by this stage; registered so wave groups resolve by id.
@export var enemy_catalog: Array[EnemyDefinition]
@export var ability_catalog: Array[AbilityDefinition]
@export var audio_catalog: Array[AudioDefinition]
@export var battle_music_id: String = "music.battle"
@export var balance: BalanceDefinition

## Scene wiring (resolved in _ready; NodePaths avoid cross-instance
## export-resolution ordering issues).
@export var entities_path: NodePath
@export var castle_path: NodePath
@export var ring_path: NodePath
@export var vfx_path: NodePath
@export var preview_path: NodePath

var wallet := EconomySystem.new()
var registry := EnemyRegistry.new()
var building := BuildingSystem.new()
var waves := WaveSystem.new()
var abilities := AbilitySystem.new()

var entities_container: Node2D = null
var castle_entity: GameEntity = null
var selection_ring: SelectionRing = null
var vfx_layer: BattleVfx = null
var placement_preview: PlacementPreview = null

var _rewards: RewardSystem = null
var _castle_system: CastleSystem = null
var _selected_tower: GameEntity = null
var _armed_definition: TowerDefinition = null
var _battle_over: bool = false

const SPEED_STEPS: Array[float] = [1.0, 2.0]
var _speed_index: int = 0


func _ready() -> void:
	# Recover clean timing when returning via scene reload.
	Engine.time_scale = 1.0
	get_tree().paused = false

	entities_container = get_node_or_null(entities_path) as Node2D
	castle_entity = get_node_or_null(castle_path) as GameEntity
	selection_ring = get_node_or_null(ring_path) as SelectionRing
	vfx_layer = get_node_or_null(vfx_path) as BattleVfx
	placement_preview = get_node_or_null(preview_path) as PlacementPreview

	var tap_layer := get_node_or_null("WorldTapLayer") as WorldTapLayer
	if tap_layer != null:
		tap_layer.controller = self

	_register_catalogs()
	_setup_audio()
	wallet.configure(stage.starting_gold if stage != null else 0)

	add_child(registry)
	var relay := EnemyEventRelay.new()
	add_child(relay)

	var lifecycle := EnemyLifecycleSystem.new()
	if vfx_layer != null:
		lifecycle.vfx_hook = vfx_layer.play_burst
	add_child(lifecycle)

	_rewards = RewardSystem.new()
	_rewards.setup(wallet)
	add_child(_rewards)

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		var progression := ProgressionTracker.new()
		progression.setup(save_manager)
		progression.castle_ratio_provider = func() -> float:
			return float(castle_current_health()) / float(maxi(castle_max_health(), 1))
		add_child(progression)

	_castle_system = CastleSystem.new()
	_castle_system.setup(castle_entity)
	add_child(_castle_system)

	building.wallet = wallet
	building.balance = balance
	building.spawn_parent = entities_container
	building.candidate_provider = registry.get_enemies
	for route_key: String in stage.paths:
		building.protected_routes.append(stage.paths[route_key])

	waves.enemy_factory = EnemyFactory.create
	waves.spawn_parent = entities_container
	add_child(waves)

	abilities.setup(ability_catalog, wallet, registry)
	if vfx_layer != null:
		abilities.vfx_hook = _on_ability_vfx
	add_child(abilities)

	if selection_ring != null:
		selection_changed.connect(selection_ring.follow)

	# Bind UI/input LAST so every system is fully wired when the HUD builds
	# bars from live catalogs.
	if placement_preview != null:
		placement_preview.controller = self
	var hud := get_node_or_null("HUD") as HudController
	if hud != null:
		hud.bind_controller(self)

	EventBus.subscribe(GameEvents.STAGE_COMPLETED, _on_stage_completed)
	EventBus.subscribe(GameEvents.CASTLE_DESTROYED, _on_castle_destroyed)
	if castle_entity != null and castle_entity.has_component(HealthComponent):
		(castle_entity.get_component(HealthComponent) as HealthComponent).configure(
				stage.castle_max_health)

	waves.start(stage)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.STAGE_COMPLETED, _on_stage_completed)
	EventBus.unsubscribe(GameEvents.CASTLE_DESTROYED, _on_castle_destroyed)


# --- Player intents (HUD calls these; UI holds no gameplay logic) ----------

func arm_building(definition: TowerDefinition) -> void:
	if _battle_over or definition == null:
		return
	_armed_definition = definition
	abilities.cancel_arm()
	clear_selection()
	build_mode_changed.emit(true)


func is_build_armed() -> bool:
	return _armed_definition != null


## Definition currently armed for placement (null when none).
func armed_definition() -> TowerDefinition:
	return _armed_definition


## Arms an ability for the next world tap; cancels build mode first.
func arm_ability(definition: AbilityDefinition) -> void:
	if _battle_over or definition == null or abilities.is_on_cooldown(definition):
		return
	cancel_building()
	abilities.arm(definition)
	build_mode_changed.emit(false)


func try_cast_ability_at(world_position: Vector2) -> bool:
	return abilities.try_cast_at(world_position)


func ability_system() -> AbilitySystem:
	return abilities


func castle_current_health() -> int:
	return _castle_system.current_health() if _castle_system != null else 0


func castle_max_health() -> int:
	return _castle_system.max_health() if _castle_system != null else 0


## Best recorded star rating for a stage from persistent progression.
func saved_stage_stars(stage_id: String) -> int:
	var save := get_node_or_null("/root/SaveManager")
	if save == null:
		return 0
	return int(save.get_section("progression").get("stages", {}).get(stage_id, 0))


func cancel_building() -> void:
	if not is_build_armed():
		return
	_armed_definition = null
	build_mode_changed.emit(false)


## Places the armed tower after BuildingSystem validation.
func try_build_at(world_position: Vector2) -> void:
	if not is_build_armed():
		return
	var tower := building.try_build(_armed_definition, world_position)
	if tower != null:
		cancel_building()


func select_tower(tower: GameEntity) -> void:
	_selected_tower = tower
	selection_changed.emit(tower)


## Placement validity at a world position for the armed tower (UI preview).
func placement_result_for(world_position: Vector2) -> Dictionary:
	if not is_build_armed():
		return {"ok": false, "reason": "not_armed"}
	return building.check_placement(_armed_definition, world_position)


## Tap routing: ability cast > tower placement > tower selection.
func handle_world_tap(world_position: Vector2) -> void:
	if abilities.armed_ability() != null:
		try_cast_ability_at(world_position)
		return
	if is_build_armed():
		try_build_at(world_position)
		return
	var picked := _pick_tower(world_position)
	if picked != null:
		select_tower(picked)
	else:
		clear_selection()


func clear_selection() -> void:
	if _selected_tower != null:
		_selected_tower = null
	selection_changed.emit(null)


func upgrade_selected() -> bool:
	if _selected_tower == null:
		return false
	return building.request_upgrade(_selected_tower)


func sell_selected() -> int:
	if _selected_tower == null:
		return -1
	var refund := building.request_sell(_selected_tower)
	if refund >= 0:
		clear_selection()
	return refund


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused


func is_paused() -> bool:
	return get_tree().paused


func cycle_speed() -> void:
	_speed_index = (_speed_index + 1) % SPEED_STEPS.size()
	Engine.time_scale = SPEED_STEPS[_speed_index]


func speed_multiplier() -> float:
	return SPEED_STEPS[_speed_index]


func selected_tower() -> GameEntity:
	return _selected_tower


# --- Internals ---------------------------------------------------------------

## Registers exported content with the ResourceManager so gameplay systems
## resolve everything through ids (SPEC-0001). Idempotent across reloads.
func _register_catalogs() -> void:
	for definition in enemy_catalog:
		if not ResourceManager.has(definition.id):
			ResourceManager.register(definition)
	for definition in tower_catalog:
		if not ResourceManager.has(definition.id):
			ResourceManager.register(definition)
	for definition in ability_catalog:
		if not ResourceManager.has(definition.id):
			ResourceManager.register(definition)
	if balance != null and not ResourceManager.has(balance.id):
		ResourceManager.register(balance)
	if stage != null and not ResourceManager.has(stage.id):
		ResourceManager.register(stage)


## Wires the global audio service with this battle's catalog and starts music.
func _setup_audio() -> void:
	var audio := get_node_or_null("/root/AudioManager")
	if audio == null:
		return
	audio.setup(audio_catalog)
	if battle_music_id != "":
		audio.play_music(battle_music_id)


func _on_ability_vfx(effect: String, position: Vector2, radius: float) -> void:
	if vfx_layer == null:
		return
	match effect:
		"explosion":
			vfx_layer.play_explosion(position, radius)
		"frost":
			vfx_layer.play_frost(position, radius)


func _pick_tower(world_position: Vector2) -> GameEntity:
	var best: GameEntity = null
	var best_distance := 64.0
	for tower in building.built_towers():
		if not is_instance_valid(tower):
			continue
		var distance := tower.position.distance_to(world_position)
		if distance < best_distance:
			best = tower
			best_distance = distance
	return best


func _on_stage_completed(_payload: Dictionary) -> void:
	if _battle_over:
		return
	_battle_over = true
	battle_ended.emit(true)
	get_tree().paused = false
	Engine.time_scale = 1.0


func _on_castle_destroyed(_payload: Dictionary) -> void:
	if _battle_over:
		return
	_battle_over = true
	waves.fail_stage()
	battle_ended.emit(false)
	get_tree().paused = false
	Engine.time_scale = 1.0
