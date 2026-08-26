## Global event dispatcher decoupling gameplay systems (SPEC-0004).
##
## Systems announce changes with publish(); unrelated systems react through
## subscribe(). Listeners never know about producers and vice versa.
##
## Deliberate design notes:
## - Payloads are Dictionaries (not event Objects) to avoid per-event heap
##   allocations on Android; treat payloads as read-only.
## - Dispatch iterates backwards so listeners may safely subscribe/unsubscribe
##   during publication without index corruption.
## - Publishing an event nobody listens to is normal and never an error.
##
## Registered as the "EventBus" autoload; intentionally has no class_name so
## the autoload identifier stays the single global access point.
extends Node

var _listeners: Dictionary = {}


## Registers [param callback] for [param event_type]. Duplicate subscriptions
## of the same callable are ignored so a listener cannot fire twice per event.
func subscribe(event_type: StringName, callback: Callable) -> void:
	if callback.is_null():
		push_error("EventBus.subscribe: callback is null for '%s'" % event_type)
		return
	if not _listeners.has(event_type):
		var fresh: Array[Callable] = []
		_listeners[event_type] = fresh
	var list: Array[Callable] = _listeners[event_type]
	if not list.has(callback):
		list.append(callback)


## Removes a previously registered callback. Unknown combinations are ignored.
func unsubscribe(event_type: StringName, callback: Callable) -> void:
	if not _listeners.has(event_type):
		return
	var list: Array[Callable] = _listeners[event_type]
	list.erase(callback)


## Delivers [param payload] to every listener of [param event_type].
## Invalid (freed-object) callables are skipped without breaking dispatch.
func publish(event_type: StringName, payload: Dictionary = {}) -> void:
	if not _listeners.has(event_type):
		return
	var list: Array[Callable] = _listeners[event_type]
	for i: int in range(list.size() - 1, -1, -1):
		if i >= list.size():
			continue
		var callback: Callable = list[i]
		if callback.is_valid():
			callback.call(payload)


## Drops every listener of one event type (used on scene/system teardown).
func clear(event_type: StringName) -> void:
	_listeners.erase(event_type)


## Drops all listeners. Intended for tests and full shutdown only.
func clear_all() -> void:
	_listeners.clear()


## Test/debug helper: number of live listeners for an event type.
func listener_count(event_type: StringName) -> int:
	if not _listeners.has(event_type):
		return 0
	return (_listeners[event_type] as Array[Callable]).size()
