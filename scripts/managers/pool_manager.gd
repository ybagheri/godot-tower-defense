## Generic object pool for frequently spawned nodes (ARCH-0001 pooling).
##
## Pools are keyed by StringName and create instances through a caller-supplied
## factory Callable, keeping the manager free of game-specific knowledge.
## Acquired nodes are shown but NOT parented by the pool: the requester decides
## where the node lives in the scene tree.
##
## Contract for pooled nodes:
## - Never call free()/queue_free() on them; return them via release().
## - release() detaches the node from its parent, hides it, and parks it.
## - Nodes above the per-pool idle cap are freed instead of parked.
##
## Registered as the "PoolManager" autoload; intentionally no class_name.
extends Node

const META_POOL_KEY: StringName = &"_pool_key"
const META_PARKED: StringName = &"_pool_parked"

var _factories: Dictionary = {}
var _idle: Dictionary = {}
var _max_idle: Dictionary = {}


## Registers (or replaces) an empty pool. Prewarms [param prewarm] instances.
func register_pool(key: StringName, factory: Callable, prewarm: int = 0, max_idle: int = 32) -> bool:
	if key.is_empty():
		push_error("PoolManager.register_pool: empty key")
		return false
	if not factory.is_valid():
		push_error("PoolManager.register_pool: invalid factory for '%s'" % key)
		return false
	_factories[key] = factory
	_max_idle[key] = maxi(max_idle, 0)
	if not _idle.has(key):
		var list: Array[Node] = []
		_idle[key] = list
	for i: int in prewarm:
		var node := _create_node(key)
		if node != null:
			_park(key, node)
	return true


func has_pool(key: StringName) -> bool:
	return _factories.has(key)


## Takes a node out of the pool (or creates one). Returns null for unknown keys.
## The returned node is visible but not attached to the scene tree yet.
func acquire(key: StringName) -> Node:
	if not _factories.has(key):
		push_error("PoolManager.acquire: unknown pool '%s'" % key)
		return null
	var list: Array[Node] = _idle[key]
	var node: Node = null
	while not list.is_empty() and node == null:
		node = list.pop_back()
		if not is_instance_valid(node):
			node = null
	if node == null:
		node = _create_node(key)
		if node == null:
			return null
	node.remove_meta(META_PARKED)
	node.show()
	return node


## Returns a pooled node to its pool, or frees it when the idle cap is full.
func release(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.has_meta(META_PARKED):
		return
	var key: StringName = node.get_meta(META_POOL_KEY, &"")
	if not _factories.has(key):
		push_error("PoolManager.release: node does not belong to any pool")
		return
	var parent := node.get_parent()
	if parent != null:
		parent.remove_child(node)
	_park(key, node)


func idle_count(key: StringName) -> int:
	if not _idle.has(key):
		return 0
	return (_idle[key] as Array[Node]).size()


func clear_pool(key: StringName) -> void:
	if not _idle.has(key):
		return
	for node: Node in _idle[key]:
		if is_instance_valid(node):
			node.free()
	(_idle[key] as Array[Node]).clear()


func clear_all() -> void:
	for key: StringName in _idle.keys():
		clear_pool(key)
	_idle.clear()
	_factories.clear()
	_max_idle.clear()


func _create_node(key: StringName) -> Node:
	var factory: Callable = _factories[key]
	var node: Node = factory.call()
	if node == null or not is_instance_valid(node) or not (node is Node):
		push_error("PoolManager: factory for '%s' did not produce a valid Node" % key)
		return null
	node.set_meta(META_POOL_KEY, key)
	node.hide()
	return node


func _park(key: StringName, node: Node) -> void:
	node.set_meta(META_PARKED, true)
	node.hide()
	var cap: int = _max_idle[key]
	var list: Array[Node] = _idle[key]
	if list.size() >= cap:
		node.free()
		return
	list.append(node)
