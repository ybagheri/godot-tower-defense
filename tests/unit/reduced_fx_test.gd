## Tests for the reduced-FX accessibility setting and stress harness math.
extends TestSuite

const VfxScript := preload("res://scripts/utilities/battle_vfx.gd")
const ShakeScript := preload("res://scripts/utilities/camera_shake.gd")

var vfx: BattleVfx = null


func setup() -> void:
	PoolManager.clear_all()
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	save_manager().reset_to_fresh()
	vfx = VfxScript.new()
	stage(vfx)


func teardown() -> void:
	for child in _root().get_children():
		if child is FloatingText or child is BurstEffect:
			_root().remove_child(child)
			child.free()
	unstage(vfx)
	vfx.free()
	PoolManager.clear_all()
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	save_manager().delete_save()


func _set_reduced(value: bool) -> void:
	var settings: Dictionary = save_manager().get_section("settings")
	settings["reduced_fx"] = value
	save_manager().store_section("settings", settings)


func test_floaters_spawn_normally_by_default() -> void:
	vfx.spawn_floating_text(Vector2.ZERO, "12", Color.WHITE)
	assert_eq(1, vfx.active_text_count(), "default allows floaters")


func test_reduced_fx_suppresses_floating_text() -> void:
	_set_reduced(true)
	vfx.spawn_floating_text(Vector2.ZERO, "12", Color.WHITE)
	assert_eq(0, vfx.active_text_count(), "reduced mode skips floaters")


func test_setting_persists_across_save_cycle() -> void:
	_set_reduced(true)
	manager_roundtrip()
	var settings: Dictionary = save_manager().get_section("settings")
	assert_true(bool(settings.get("reduced_fx", false)), "flag survives save/load")


func manager_roundtrip() -> void:
	save_manager().save_game()
	save_manager().data = {}
	save_manager().load_game()


func test_camera_shake_gated_by_reduced_mode() -> void:
	var shake: CameraShake = ShakeScript.new()
	stage(shake)
	_set_reduced(false)
	shake.add_trauma(0.5)
	assert_almost_eq(0.5, shake.trauma, 0.001, "normal mode shakes")
	_set_reduced(true)
	shake.add_trauma(0.5)
	assert_almost_eq(0.5, shake.trauma, 0.001, "reduced mode adds nothing")
	unstage(shake)
	shake.free()
