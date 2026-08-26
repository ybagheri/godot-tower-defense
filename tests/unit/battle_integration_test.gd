## Integration test: a complete deterministic mini-battle (SPEC-0005/0006/0010).
##
## Simulates the full value chain headlessly: wave starts -> enemies spawn ->
## follow the path -> towers kill them -> gold flows -> next wave -> castle
## damage on arrival -> stage completion / failure.
extends TestSuite

var goblin := EnemyDefinition.new()
var route := PathDefinition.new()
var stage_def := StageDefinition.new()

var container := Node2D.new()
var relay := EnemyEventRelay.new()
var registry := EnemyRegistry.new()
var wallet := EconomySystem.new()
var rewards := RewardSystem.new()
var waves := WaveSystem.new()

var events := {}


func setup() -> void:
	ResourceManager.clear()
	EnemyFactory.reset_counter()
	PoolManager.clear_all()
	for event_name: StringName in [
		GameEvents.WAVE_STARTED, GameEvents.WAVE_COMPLETED,
		GameEvents.BOSS_WAVE_STARTED, GameEvents.STAGE_COMPLETED,
		GameEvents.STAGE_FAILED, GameEvents.ENEMY_REACHED_GOAL,
		GameEvents.CURRENCY_CHANGED, GameEvents.ENEMY_DIED,
	]:
		EventBus.clear(event_name)
	events = {
		"wave_started": 0, "wave_completed": 0, "boss_started": 0,
		"stage_completed": 0, "stage_failed": 0, "goal_reached": 0,
	}
	EventBus.subscribe(GameEvents.WAVE_STARTED, func(_p: Dictionary) -> void:
		events.wave_started += 1)
	EventBus.subscribe(GameEvents.WAVE_COMPLETED, func(_p: Dictionary) -> void:
		events.wave_completed += 1)
	EventBus.subscribe(GameEvents.BOSS_WAVE_STARTED, func(_p: Dictionary) -> void:
		events.boss_started += 1)
	EventBus.subscribe(GameEvents.STAGE_COMPLETED, func(_p: Dictionary) -> void:
		events.stage_completed += 1)
	EventBus.subscribe(GameEvents.STAGE_FAILED, func(_p: Dictionary) -> void:
		events.stage_failed += 1)
	EventBus.subscribe(GameEvents.ENEMY_REACHED_GOAL, func(_p: Dictionary) -> void:
		events.goal_reached += 1)

	goblin = EnemyDefinition.new()
	goblin.id = "enemy.goblin.basic"
	goblin.display_name = "Goblin"
	goblin.max_health = 10
	goblin.speed = 100.0
	goblin.reward_gold = 5
	goblin.damage_to_castle = 2
	assert_true(ResourceManager.register(goblin), "goblin registered")

	route = PathDefinition.new()
	route.id = "stage001.main"
	route.waypoints = PackedVector2Array([Vector2(0, 0), Vector2(200, 0)])

	stage_def = StageDefinition.new()
	stage_def.id = "stage.test"
	stage_def.prep_time_seconds = 0.0
	# Groups reference routes by PathDefinition id; catalog must use same keys.
	stage_def.paths = {route.id: route}

	container = Node2D.new()
	stage(container)
	relay = EnemyEventRelay.new()
	stage(relay)
	registry = EnemyRegistry.new()
	stage(registry)
	wallet = EconomySystem.new()
	rewards = RewardSystem.new()
	rewards.setup(wallet)
	stage(rewards)
	waves = WaveSystem.new()
	waves.enemy_factory = EnemyFactory.create
	waves.spawn_parent = container
	stage(waves)


func teardown() -> void:
	for event_name: StringName in [
		GameEvents.WAVE_STARTED, GameEvents.WAVE_COMPLETED,
		GameEvents.BOSS_WAVE_STARTED, GameEvents.STAGE_COMPLETED,
		GameEvents.STAGE_FAILED, GameEvents.ENEMY_REACHED_GOAL,
		GameEvents.CURRENCY_CHANGED, GameEvents.ENEMY_DIED,
	]:
		EventBus.clear(event_name)
	ResourceManager.clear()
	unstage(waves)
	unstage(rewards)
	unstage(registry)
	unstage(relay)
	unstage(container)
	waves.free()
	rewards.free()
	registry.free()
	relay.free()
	container.free()


func _one_wave_wave(count: int, reward: int = 50, boss: bool = false) -> WaveDefinition:
	var group := SpawnGroupDefinition.new()
	group.enemy_id = goblin.id
	group.count = count
	group.spawn_interval = 0.0
	group.initial_delay = 0.0
	group.path_id = route.id
	var wave := WaveDefinition.new()
	wave.wave_number = 1
	wave.reward_gold = reward
	wave.is_boss_wave = boss
	wave.spawn_groups = [group]
	return wave


func _two_goblins_stage() -> void:
	stage_def.waves = [_one_wave_wave(2)]
	wallet.configure(0)
	waves.start(stage_def)


func test_full_kill_loop_pays_and_completes() -> void:
	_two_goblins_stage()
	assert_eq(WaveSystem.State.ACTIVE, waves.state,
			"zero-prep wave spawned synchronously and went active")
	assert_eq(2, registry.count(), "both goblins alive immediately")

	for enemy: GameEntity in registry.get_enemies():
		CombatSystem.resolve_hit(enemy, null, 999, DamageTypes.Type.PHYSICAL)
	assert_eq(0, registry.count(), "registry forgets the dead")

	waves.advance(0.01)
	assert_eq(1, events.wave_completed, "wave completed once")
	assert_eq(1, events.stage_completed, "single-wave stage finished")
	assert_eq(60, wallet.gold, "2 kills x5 + 50 wave bonus")
	assert_eq(WaveSystem.State.COMPLETED, waves.state, "battle over")


func test_goal_reach_damages_castle_wallet_and_registry() -> void:
	_two_goblins_stage()
	assert_eq(2, registry.count(), "goblins ready")

	var castle_damage_taken := [0]
	var mover := container.get_child(0)
	var mover_loot: LootComponent = mover.get_component(LootComponent)
	castle_damage_taken[0] = mover_loot.damage_to_castle

	var movement: MovementComponent = mover.get_component(MovementComponent)
	movement.advance(3.0)
	assert_eq(1, events.goal_reached, "first goblin reached the gate")

	CombatSystem.resolve_hit(container.get_child(1), null, 999, DamageTypes.Type.PHYSICAL)
	waves.advance(0.01)
	assert_eq(1, events.wave_completed, "wave completes when last enemy is gone")
	assert_eq(55, wallet.gold, "one kill (5) + wave bonus (50)")
	assert_eq(2, castle_damage_taken[0], "reached goblin carries 2 castle damage")


func test_multi_wave_preparation_cycle() -> void:
	stage_def.prep_time_seconds = 2.0
	stage_def.waves = [
		_one_wave_wave(1, 10),
		_one_wave_wave(1, 20),
	]
	wallet.configure(0)
	waves.start(stage_def)
	assert_eq(WaveSystem.State.PREPARING, waves.state, "prep timer holds wave one")
	waves.advance(2.01)
	assert_eq(1, events.wave_started, "wave one started after preparation")
	assert_eq(1, registry.count(), "wave one goblin present")

	CombatSystem.resolve_hit(container.get_child(0), null, 999, DamageTypes.Type.PHYSICAL)
	waves.advance(0.01)
	assert_eq(1, events.wave_completed, "wave one done")
	assert_eq(WaveSystem.State.PREPARING, waves.state, "preparing wave two")
	assert_eq(15, wallet.gold, "kill 5 + wave-one bonus 10")

	waves.advance(2.0)
	assert_eq(2, events.wave_started, "second wave began after full preparation")
	var second_goblin := container.get_child(1)
	CombatSystem.resolve_hit(second_goblin, null, 999, DamageTypes.Type.PHYSICAL)
	waves.advance(0.01)
	assert_eq(2, events.wave_completed, "wave two done")
	assert_eq(1, events.stage_completed, "stage finished after final wave")
	assert_eq(40, wallet.gold, "kills 5+5, bonuses 10+20")


func test_boss_wave_flag_publishes_special_event() -> void:
	stage_def.waves = [_one_wave_wave(1, 0, true)]
	wallet.configure(0)
	waves.start(stage_def)
	waves.advance(0.01)
	assert_eq(1, events.boss_started, "boss warning published")
	assert_eq(1, events.wave_started, "regular start also fires for uniform handling")


func test_fail_stage_stops_battle() -> void:
	_two_goblins_stage()
	waves.advance(0.01)
	waves.fail_stage()
	assert_eq(1, events.stage_failed, "failure announced")
	assert_eq(WaveSystem.State.FAILED, waves.state, "failed state")
	waves.fail_stage()
	assert_eq(1, events.stage_failed, "idempotent failure")


func test_unknown_enemy_id_does_not_crash_spawner() -> void:
	var broken_group := SpawnGroupDefinition.new()
	broken_group.enemy_id = "enemy.does.not.exist"
	broken_group.count = 1
	broken_group.path_id = route.id
	var bad_wave := WaveDefinition.new()
	bad_wave.spawn_groups = [broken_group]
	stage_def.waves = [bad_wave]
	wallet.configure(0)
	waves.start(stage_def)
	waves.advance(0.05)
	assert_eq(0, registry.count(), "nothing spawned")
	assert_eq(WaveSystem.State.COMPLETED, waves.state,
			"empty wave resolves instantly through completion path")
