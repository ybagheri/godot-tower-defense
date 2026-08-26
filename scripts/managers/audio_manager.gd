## Central audio service: event-driven playback with sound limiting
## (SPEC-0014). Gameplay never calls this directly; it publishes events.
##
## The catalog is injected by battle wiring; the manager maps gameplay events
## to sound ids and throttles repeats so 100 arrow hits do not stack into
## 100 overlapping voices.
extends Node

const EVENT_MAP := {
	&"tower_built": ["sfx.build"],
	&"tower_upgraded": ["sfx.upgrade"],
	&"tower_sold": ["sfx.sell"],
	&"enemy_died": ["sfx.death"],
	&"castle_damaged": ["sfx.castle_hit"],
	&"stage_completed": ["sfx.victory"],
	&"stage_failed": ["sfx.defeat"],
	&"ability_cast_started": ["sfx.cast"],
}

const MAX_EFFECT_VOICES: int = 10

var _catalog: Dictionary = {}
var _last_played_ms: Dictionary = {}
var _effect_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _current_music_id: String = ""
## Stable per-event bound callables so unsubscribe() matches subscribe().
var _bindings: Dictionary = {}


## Registers the playable catalog; invalid entries are skipped with an error.
func setup(catalog: Array[AudioDefinition]) -> void:
	for definition in catalog:
		var report: Dictionary = definition.validate()
		if not (report.errors as PackedStringArray).is_empty():
			push_error("AudioManager: skipping invalid '%s'" % definition.id)
			continue
		_catalog[definition.id] = definition


func _ready() -> void:
	for event_name: StringName in EVENT_MAP.keys():
		var bound := _on_game_event.bind(event_name)
		_bindings[event_name] = bound
		EventBus.subscribe(event_name, bound)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	_music_player.finished.connect(_loop_music)
	add_child(_music_player)


func _exit_tree() -> void:
	for event_name: StringName in EVENT_MAP.keys():
		EventBus.unsubscribe(event_name, _bindings[event_name])


func play_effect(sound_id: String) -> bool:
	var definition: AudioDefinition = _catalog.get(sound_id)
	if definition == null:
		return false
	var now := Time.get_ticks_msec()
	var last := int(_last_played_ms.get(sound_id, -1000))
	if now - last < definition.min_interval_ms:
		return false
	var player := _acquire_voice()
	if player == null:
		return false
	player.stream = load(definition.stream_path)
	player.volume_db = definition.volume_db
	player.bus = definition.bus_category
	player.play()
	_last_played_ms[sound_id] = now
	return true


func play_music(music_id: String) -> bool:
	var definition: AudioDefinition = _catalog.get(music_id)
	if definition == null or _current_music_id == music_id:
		return false
	_music_player.stream = load(definition.stream_path)
	_music_player.volume_db = definition.volume_db
	_music_player.play()
	_current_music_id = music_id
	return true


func stop_music() -> void:
	_current_music_id = ""
	_music_player.stop()


func set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_warning("AudioManager: unknown bus '%s'" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(clampf(linear, 0.0001, 1.0)))


func known_sound(sound_id: String) -> bool:
	return _catalog.has(sound_id)


func is_music_playing() -> bool:
	return _music_player.playing


func _acquire_voice() -> AudioStreamPlayer:
	for player in _effect_players:
		if not player.playing:
			return player
	if _effect_players.size() >= MAX_EFFECT_VOICES:
		return null
	var player := AudioStreamPlayer.new()
	add_child(player)
	_effect_players.append(player)
	return player


func _loop_music() -> void:
	if _current_music_id != "":
		_music_player.play()


func _on_game_event(payload: Dictionary, event_name: StringName) -> void:
	for sound_id: String in EVENT_MAP[event_name]:
		play_effect(sound_id)
	# Battle music makes way for the result sting.
	if event_name == &"stage_completed" or event_name == &"stage_failed":
		stop_music()
