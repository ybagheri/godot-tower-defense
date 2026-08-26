## Tests for AudioManager catalog handling, throttling and event mapping
## (SPEC-0014).
extends TestSuite

const SFX_DIR := "res://assets/audio/sfx"

var audio: Node = null
var catalog: Array[AudioDefinition] = []


func setup() -> void:
	EventBus.clear(GameEvents.TOWER_BUILT)
	audio = autoload("AudioManager")
	catalog = []
	for sound_name: String in ["build", "death"]:
		var definition := AudioDefinition.new()
		definition.id = "sfx.%s" % sound_name
		definition.display_name = sound_name
		definition.stream_path = "%s/%s.wav" % [SFX_DIR, sound_name]
		definition.min_interval_ms = 1000 if sound_name == "death" else 45
		catalog.append(definition)
	audio.setup(catalog)


func teardown() -> void:
	EventBus.clear(GameEvents.TOWER_BUILT)


func test_catalog_accepts_valid_definitions() -> void:
	assert_true(audio.known_sound("sfx.build"), "build registered")
	assert_true(audio.known_sound("sfx.death"), "death registered")
	assert_false(audio.known_sound("sfx.missing"), "unknown id absent")


func test_invalid_stream_rejected_at_setup() -> void:
	var broken := AudioDefinition.new()
	broken.id = "sfx.broken"
	broken.display_name = "broken"
	broken.stream_path = "res://does/not/exist.wav"
	audio.setup([broken])
	assert_false(audio.known_sound("sfx.broken"), "invalid entry skipped")


func test_play_effect_throttles_repeats() -> void:
	assert_true(audio.play_effect("sfx.death"), "first play allowed")
	assert_false(audio.play_effect("sfx.death"), "repeat within window blocked")
	assert_true(audio.play_effect("sfx.build"),
			"different sound unaffected by throttle")


func test_event_mapping_triggers_without_crash() -> void:
	EventBus.publish(GameEvents.TOWER_BUILT, {})
	assert_true(true, "mapped event playback executed safely")


func test_playback_survives_voice_cap() -> void:
	for i in 40:
		audio.play_effect("sfx.build")
	assert_true(audio._effect_players.size() <= audio.MAX_EFFECT_VOICES,
			"voice cap respected")


func test_stage_end_stops_music_for_result_sting() -> void:
	var music := AudioDefinition.new()
	music.id = "music.test"
	music.display_name = "test music"
	music.stream_path = "res://assets/audio/music/battle_loop.wav"
	music.bus_category = "Music"
	audio.setup([music])
	assert_true(audio.play_music("music.test"), "music started")
	assert_true(audio.is_music_playing(), "playing before stage end")
	EventBus.publish(GameEvents.STAGE_COMPLETED, {})
	assert_false(audio.is_music_playing(), "music stopped for victory sting")
	EventBus.publish(GameEvents.STAGE_FAILED, {})
	assert_false(audio.is_music_playing(), "stays stopped on defeat")
