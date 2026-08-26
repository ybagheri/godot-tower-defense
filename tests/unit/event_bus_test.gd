## Unit tests for the EventBus (SPEC-0004).
extends TestSuite

var _captured: Dictionary = {}
var _call_log: PackedStringArray = []


func setup() -> void:
	event_bus().clear_all()
	_captured = {}
	_call_log = PackedStringArray()


func teardown() -> void:
	event_bus().clear_all()


func _capture(payload: Dictionary) -> void:
	_captured = payload


func _mark_a(_payload: Dictionary) -> void:
	_call_log.append("a")


func _mark_b(_payload: Dictionary) -> void:
	_call_log.append("b")


func _mark_c(_payload: Dictionary) -> void:
	_call_log.append("c")


func test_publish_without_listeners_is_allowed() -> void:
	var bus := event_bus()
	bus.publish(GameEvents.ENEMY_DIED, {"enemy_id": "enemy.goblin.basic"})
	assert_eq(0, bus.listener_count(GameEvents.ENEMY_DIED), "no listeners registered")


func test_subscribe_and_publish_delivers_payload() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.ENEMY_DIED, _capture)
	bus.publish(GameEvents.ENEMY_DIED, {"enemy_id": "enemy.orc.brute", "reward": 25})
	assert_eq("enemy.orc.brute", _captured.get("enemy_id"), "payload delivered")
	assert_eq(25, _captured.get("reward"), "second field delivered")


func test_publish_uses_empty_payload_by_default() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.WAVE_STARTED, _capture)
	bus.publish(GameEvents.WAVE_STARTED)
	assert_eq(0, _captured.size(), "default payload is empty dictionary")


func test_multiple_listeners_all_called() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.TOWER_BUILT, _mark_a)
	bus.subscribe(GameEvents.TOWER_BUILT, _mark_b)
	bus.subscribe(GameEvents.TOWER_BUILT, _mark_c)
	bus.publish(GameEvents.TOWER_BUILT)
	assert_eq(3, _call_log.size(), "all listeners called once")


func test_duplicate_subscription_called_once() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.TOWER_BUILT, _mark_a)
	bus.subscribe(GameEvents.TOWER_BUILT, _mark_a)
	assert_eq(1, bus.listener_count(GameEvents.TOWER_BUILT), "duplicate ignored")
	bus.publish(GameEvents.TOWER_BUILT)
	assert_eq(1, _call_log.size(), "listener fired exactly once")


func test_unsubscribe_stops_delivery() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.ENEMY_SPAWNED, _capture)
	bus.unsubscribe(GameEvents.ENEMY_SPAWNED, _capture)
	bus.publish(GameEvents.ENEMY_SPAWNED)
	assert_eq({}, _captured, "no delivery after unsubscribe")
	assert_eq(0, bus.listener_count(GameEvents.ENEMY_SPAWNED), "listener removed")


func test_unsubscribe_unknown_combination_is_safe() -> void:
	var bus := event_bus()
	bus.unsubscribe(GameEvents.ENEMY_SPAWNED, _capture)
	bus.subscribe(GameEvents.ENEMY_SPAWNED, _capture)
	bus.unsubscribe(GameEvents.CASTLE_DAMAGED, _capture)
	assert_eq(1, bus.listener_count(GameEvents.ENEMY_SPAWNED), "unrelated unsubscribe is harmless")


func test_listener_may_unsubscribe_during_dispatch() -> void:
	var bus := event_bus()
	var remover: Callable = func(_payload: Dictionary) -> void:
		bus.unsubscribe(GameEvents.STAGE_COMPLETED, _mark_b)
	bus.subscribe(GameEvents.STAGE_COMPLETED, remover)
	bus.subscribe(GameEvents.STAGE_COMPLETED, _mark_b)
	bus.subscribe(GameEvents.STAGE_COMPLETED, _mark_c)
	bus.publish(GameEvents.STAGE_COMPLETED)
	assert_eq(2, _call_log.size(), "dispatch finished consistently despite mutation")
	assert_eq("b", _call_log[1], "listeners already dispatched stay dispatched")
	assert_eq(2, bus.listener_count(GameEvents.STAGE_COMPLETED), "unsubscription applied")
	_call_log.clear()
	bus.publish(GameEvents.STAGE_COMPLETED)
	assert_eq(1, _call_log.size(), "removed listener not called again")
	assert_eq("c", _call_log[0], "remaining listeners still served")


func test_clear_all_removes_everything() -> void:
	var bus := event_bus()
	bus.subscribe(GameEvents.DAMAGE_DEALT, _mark_a)
	bus.subscribe(GameEvents.ENEMY_DIED, _mark_b)
	bus.clear_all()
	assert_eq(0, bus.listener_count(GameEvents.DAMAGE_DEALT), "cleared a")
	assert_eq(0, bus.listener_count(GameEvents.ENEMY_DIED), "cleared b")
