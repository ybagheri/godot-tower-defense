## Drives battle rhythm: preparation, spawn timelines, wave completion
## (SPEC-0005).
##
## The system never creates enemies itself: spawning is delegated through an
## injected factory Callable (usually EnemyFactory.create). Completion is
## detected by tracking spawned enemies until all have died or reached the
## castle. All progression announcements go through the EventBus.
##
## Timing is driven by advance(delta) (also wired to _process) so tests can
## simulate battles deterministically without waiting frames.
class_name WaveSystem
extends Node

enum State { IDLE, PREPARING, SPAWNING, ACTIVE, COMPLETED, FAILED }

signal state_changed(new_state: State)

var state: State = State.IDLE
var current_wave_number: int = 0

var _stage: StageDefinition = null
var _wave_index: int = -1
var _prep_remaining: float = 0.0
var _elapsed: float = 0.0
var _timeline: Array[Dictionary] = []
var _timeline_cursor: int = 0
var _alive_ids: Dictionary = {}

## Callable(enemy_definition, path_definition, parent) -> GameEntity
var enemy_factory: Callable = Callable()
## Container receiving created enemies.
var spawn_parent: Node = null


func start(stage_definition: StageDefinition) -> void:
	if enemy_factory.is_null():
		push_error("WaveSystem.start: no enemy_factory callable assigned")
		return
	_stage = stage_definition
	_wave_index = -1
	current_wave_number = 0
	_begin_preparation()
	# Zero-preparation stages begin (and may fully spawn) synchronously so
	# battles are deterministic from the moment start() returns.
	if state == State.PREPARING and _prep_remaining <= 0.0:
		_begin_wave()
		_evaluate_battle_state()


func _begin_preparation() -> void:
	if _wave_index + 1 >= _stage.waves.size():
		_finish_stage()
		return
	_wave_index += 1
	var wave := _stage.waves[_wave_index]
	current_wave_number = wave.wave_number
	_prep_remaining = _stage.prep_time_seconds
	_set_state(State.PREPARING)


func _begin_wave() -> void:
	var wave := _stage.waves[_wave_index]
	_elapsed = 0.0
	_timeline_cursor = 0
	_alive_ids.clear()
	_timeline.clear()

	for group: SpawnGroupDefinition in wave.spawn_groups:
		var definition := ResourceManager.require(group.enemy_id) as EnemyDefinition
		if definition == null:
			push_error("WaveSystem: unknown enemy '%s' in %s" % [group.enemy_id, wave.id])
			continue
		var path := _stage.get_route(group.path_id)
		if path == null:
			push_error("WaveSystem: unknown path '%s' in %s" % [group.path_id, wave.id])
			continue
		var spawn_time := group.initial_delay
		for i: int in group.count:
			_timeline.append({"time": spawn_time, "definition": definition, "path": path})
			spawn_time += group.spawn_interval

	_timeline.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.time < b.time)

	if wave.is_boss_wave:
		EventBus.publish(GameEvents.BOSS_WAVE_STARTED,
				{"wave_number": wave.wave_number})
	EventBus.publish(GameEvents.WAVE_STARTED,
			{"wave_number": wave.wave_number, "is_boss": wave.is_boss_wave})
	_set_state(State.SPAWNING)


func _finish_stage() -> void:
	EventBus.publish(GameEvents.STAGE_COMPLETED, {"stage_id": _stage.id})
	_set_state(State.COMPLETED)


## External defeat hook (castle destroyed): stops the battle immediately.
func fail_stage() -> void:
	if state == State.FAILED or state == State.COMPLETED:
		return
	EventBus.publish(GameEvents.STAGE_FAILED, {"stage_id": _stage.id if _stage != null else ""})
	_set_state(State.FAILED)


## Seconds left before the next wave begins (0 outside preparation).
func preparation_seconds_remaining() -> float:
	return _prep_remaining if state == State.PREPARING else 0.0


## Enemies still to spawn in the current wave (HUD readout).
func spawns_remaining_in_wave() -> int:
	return _timeline.size() - _timeline_cursor


## Advances simulation time; also called from _process during play.
func advance(delta: float) -> void:
	match state:
		State.PREPARING:
			_prep_remaining -= delta
			if _prep_remaining <= 0.0:
				_begin_wave()
				_evaluate_battle_state()
		State.SPAWNING, State.ACTIVE:
			_elapsed += delta
			_evaluate_battle_state()
		_:
			pass


## Spawns everything due at the current elapsed time and completes the wave
## once the timeline is exhausted and no spawned enemy remains.
func _evaluate_battle_state() -> void:
	while _timeline_cursor < _timeline.size():
		var entry: Dictionary = _timeline[_timeline_cursor]
		if entry.time > _elapsed:
			break
		_spawn_enemy(entry)
		_timeline_cursor += 1
	if state == State.SPAWNING and _timeline_cursor >= _timeline.size():
		_set_state(State.ACTIVE)
	if state == State.ACTIVE and _timeline_cursor >= _timeline.size() and _alive_ids.is_empty():
		_complete_wave()


func _spawn_enemy(entry: Dictionary) -> void:
	var entity: GameEntity = enemy_factory.call(entry.definition, entry.path, spawn_parent)
	if entity == null:
		push_error("WaveSystem: factory produced no enemy")
		return
	_alive_ids[entity.get_instance_id()] = true


func _complete_wave() -> void:
	var wave := _stage.waves[_wave_index]
	EventBus.publish(GameEvents.WAVE_COMPLETED,
			{"wave_number": wave.wave_number, "reward_gold": wave.reward_gold})
	_begin_preparation()


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENEMY_DIED, _on_enemy_gone)
	EventBus.subscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENEMY_DIED, _on_enemy_gone)
	EventBus.unsubscribe(GameEvents.ENEMY_REACHED_GOAL, _on_enemy_reached_goal)


func _on_enemy_gone(payload: Dictionary) -> void:
	var entity := payload.get("entity") as GameEntity
	if entity != null and _alive_ids.has(entity.get_instance_id()):
		_alive_ids.erase(entity.get_instance_id())


func _on_enemy_reached_goal(payload: Dictionary) -> void:
	_on_enemy_gone(payload)


func _process(delta: float) -> void:
	advance(delta)
