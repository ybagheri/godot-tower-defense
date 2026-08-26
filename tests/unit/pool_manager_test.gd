## Unit tests for the PoolManager (ARCH-0001 object pooling).
extends TestSuite

const TEST_POOL: StringName = &"test_node"


func setup() -> void:
	pool_manager().clear_all()
	pool_manager().register_pool(TEST_POOL, _create_label, 0, 4)


func teardown() -> void:
	pool_manager().clear_all()


func _create_label() -> Node:
	return Label.new()


func test_acquire_creates_new_instance() -> void:
	var node: Node = pool_manager().acquire(TEST_POOL)
	assert_not_null(node, "instance produced")
	assert_true(node.visible, "acquired nodes are visible")
	node.free()


func test_release_and_reuse_same_instance() -> void:
	var first: Node = pool_manager().acquire(TEST_POOL)
	pool_manager().release(first)
	assert_eq(1, pool_manager().idle_count(TEST_POOL), "node parked")
	var second: Node = pool_manager().acquire(TEST_POOL)
	assert_eq(first, second, "parked instance reused")
	assert_eq(0, pool_manager().idle_count(TEST_POOL), "pool drained")
	second.free()


func test_prewarm_fills_pool() -> void:
	pool_manager().clear_all()
	pool_manager().register_pool(TEST_POOL, _create_label, 3, 8)
	assert_eq(3, pool_manager().idle_count(TEST_POOL), "prewarmed instances parked")


func test_idle_cap_frees_excess_nodes() -> void:
	pool_manager().clear_all()
	pool_manager().register_pool(TEST_POOL, _create_label, 0, 2)
	var nodes: Array[Node] = []
	for i: int in 5:
		nodes.append(pool_manager().acquire(TEST_POOL))
	for node: Node in nodes:
		pool_manager().release(node)
	assert_eq(2, pool_manager().idle_count(TEST_POOL), "cap respected")


func test_double_release_is_ignored() -> void:
	var node: Node = pool_manager().acquire(TEST_POOL)
	pool_manager().release(node)
	pool_manager().release(node)
	assert_eq(1, pool_manager().idle_count(TEST_POOL), "second release ignored")


func test_acquire_unknown_key_returns_null() -> void:
	assert_null(pool_manager().acquire(&"missing_pool"), "unknown key is null")


func test_clear_all_frees_parked_nodes() -> void:
	var node: Node = pool_manager().acquire(TEST_POOL)
	pool_manager().release(node)
	pool_manager().clear_all()
	assert_eq(0, pool_manager().idle_count(TEST_POOL), "pool emptied")
