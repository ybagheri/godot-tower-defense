## Tests for polish systems: camera shake, boss lookup, theme wiring.
extends TestSuite

const ShakeScript := preload("res://scripts/utilities/camera_shake.gd")
const THEME := preload("res://resources/ui/theme_dark_medieval.tres")
const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func setup() -> void:
	EventBus.clear(GameEvents.CASTLE_DAMAGED)
	EventBus.clear(GameEvents.ABILITY_EXECUTED)


func teardown() -> void:
	EventBus.clear(GameEvents.CASTLE_DAMAGED)
	EventBus.clear(GameEvents.ABILITY_EXECUTED)


func _shake() -> CameraShake:
	var shake: CameraShake = ShakeScript.new()
	stage(shake)
	return shake


func test_trauma_adds_and_decays() -> void:
	var shake := _shake()
	shake.add_trauma(0.5)
	assert_almost_eq(0.5, shake.trauma, 0.001, "trauma stored")
	shake.advance(1.0)
	assert_almost_eq(0.0, shake.trauma, 0.001, "decayed past one second")
	unstage(shake)
	shake.free()


func test_trauma_clamps_to_one() -> void:
	var shake := _shake()
	for i in 10:
		shake.add_trauma(0.4)
	assert_almost_eq(1.0, shake.trauma, 0.001, "clamped at maximum")
	unstage(shake)
	shake.free()


func test_shake_offset_bounded_and_settles() -> void:
	var shake := _shake()
	shake.max_offset = 12.0
	shake.add_trauma(1.0)
	shake.advance(0.05)
	var magnitude := shake.offset.length()
	assert_true(magnitude <= 12.0 + 0.001,
			"offset within max bound (got %.2f)" % magnitude)
	for i in 60:
		shake.advance(0.05)
	assert_almost_eq(0.0, shake.offset.length(), 0.001, "settles to rest")
	unstage(shake)
	shake.free()


func test_castle_event_drives_shake() -> void:
	var shake := _shake()
	EventBus.publish(GameEvents.CASTLE_DAMAGED, {"current": 90, "max": 100})
	assert_true(shake.trauma > 0.0, "castle damage shakes the screen")
	unstage(shake)
	shake.free()


func test_ability_hit_drives_shake_but_miss_does_not() -> void:
	var shake := _shake()
	EventBus.publish(GameEvents.ABILITY_EXECUTED, {"hits": 3})
	assert_true(shake.trauma > 0.0, "impactful ability shakes")
	unstage(shake)
	shake = _shake()
	EventBus.publish(GameEvents.ABILITY_EXECUTED, {"hits": 0})
	assert_almost_eq(0.0, shake.trauma, 0.001, "whiffed cast stays calm")
	unstage(shake)
	shake.free()


func test_registry_boss_lookup() -> void:
	var registry := EnemyRegistry.new()
	stage(registry)

	var grunt := GameEntity.new()
	grunt.position = Vector2.ZERO
	var g_health := HealthComponent.new()
	grunt.add_component(g_health)
	g_health.configure(50)
	stage(grunt)

	var boss := GameEntity.new()
	boss.position = Vector2(30, 0)
	boss.add_tag("boss")
	var b_health := HealthComponent.new()
	boss.add_component(b_health)
	b_health.configure(500)
	stage(boss)

	registry._on_enemy_spawned({"entity": grunt})
	registry._on_enemy_spawned({"entity": boss})

	var found := registry.get_boss()
	assert_eq(boss, found, "living boss returned")

	b_health.receive_damage(500)
	assert_null(registry.get_boss(), "dead boss ignored")

	unstage(registry)
	registry.free()


func test_theme_wired_into_ui_scenes() -> void:
	var menu := MENU_SCENE.instantiate()
	var menu_theme: Theme = (menu as Control).theme
	assert_not_null(menu_theme, "menu themed")
	menu.free()

	var hud := HUD_SCENE.instantiate()
	var root := hud.get_node("Root") as Control
	assert_not_null(root.theme, "hud themed")
	hud.free()
	assert_eq(menu_theme, THEME, "menu uses shipped dark medieval theme")


func test_result_overlay_has_menu_transition_button() -> void:
	var hud := HUD_SCENE.instantiate()
	var menu_button: Button = hud.get_node("%MenuButton")
	assert_not_null(menu_button, "menu button exists on result overlay")
	assert_false(menu_button.disabled, "menu button enabled")
	hud.free()
