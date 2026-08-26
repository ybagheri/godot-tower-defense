## Tests for polish-layer VFX: floating damage numbers and gold popups.
extends TestSuite

const VfxScript := preload("res://scripts/utilities/battle_vfx.gd")

var vfx: BattleVfx = null


func setup() -> void:
	PoolManager.clear_all()
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	EventBus.clear(GameEvents.GOLD_EARNED)
	vfx = VfxScript.new()
	stage(vfx)


func teardown() -> void:
	# Floaters/bursts parent to the root, not to this layer: sweep orphans
	# so they cannot leak into later tests.
	for child in _root().get_children():
		if child is FloatingText or child is BurstEffect:
			_root().remove_child(child)
			child.free()
	unstage(vfx)
	vfx.free()
	PoolManager.clear_all()
	EventBus.clear(GameEvents.DAMAGE_DEALT)
	EventBus.clear(GameEvents.GOLD_EARNED)


func _staged_target() -> GameEntity:
	var target := GameEntity.new()
	target.position = Vector2(100, 100)
	stage(target)
	return target


func test_damage_event_spawns_floater() -> void:
	var target := _staged_target()
	EventBus.publish(GameEvents.DAMAGE_DEALT,
			{"target": target, "amount": 12, "critical": false})
	assert_eq(1, vfx.active_text_count(), "one floater for one hit")
	unstage(target)
	target.free()


func test_critical_hits_are_marked() -> void:
	var target := _staged_target()
	EventBus.publish(GameEvents.DAMAGE_DEALT,
			{"target": target, "amount": 30, "critical": true})
	assert_eq(1, vfx.active_text_count(), "critical spawns too")
	unstage(target)
	target.free()


func test_gold_popup_uses_event_position() -> void:
	EventBus.publish(GameEvents.GOLD_EARNED,
			{"source": "enemy_died", "amount": 8, "position": Vector2(50, 60)})
	assert_eq(1, vfx.active_text_count(), "gold popup spawned")
	EventBus.publish(GameEvents.GOLD_EARNED,
			{"source": "wave_completed", "amount": 50})
	assert_eq(1, vfx.active_text_count(), "non-kill gold stays quiet")


func test_floater_cap_limits_screen_flood() -> void:
	for i in 40:
		vfx.spawn_floating_text(Vector2(i, 0), str(i), Color.WHITE)
	assert_eq(vfx.MAX_FLOATING_TEXTS, vfx.active_text_count(), "cap respected")


func test_retire_returns_to_pool_and_decrements() -> void:
	vfx.spawn_floating_text(Vector2(10, 0), "7", Color.WHITE)
	vfx.spawn_floating_text(Vector2(30, 0), "9", Color.WHITE)
	assert_eq(2, vfx.active_text_count(), "two floaters active")

	var idle_before := PoolManager.idle_count(&"vfx_text")
	for child in stage_root_children():
		if child is FloatingText:
			(child as FloatingText).advance((child as FloatingText).lifetime + 0.01)
	assert_eq(0, vfx.active_text_count(), "counter cleared on retire")
	assert_eq(idle_before + 2, PoolManager.idle_count(&"vfx_text"),
			"both floaters returned to the pool")


func stage_root_children() -> Array[Node]:
	var nodes: Array[Node] = []
	for child in _root().get_children():
		nodes.append(child)
	return nodes
