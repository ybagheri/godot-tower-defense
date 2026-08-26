## Minimal assertion base for the project's headless test harness.
##
## Suites are discovered by tests/test_runner.gd, which instantiates every
## tests/unit/*_test.gd script, calls setup()/teardown() around each test
## method (any method whose name starts with "test_" and takes no arguments),
## and reports a non-zero exit code when assertions fail.
class_name TestSuite
extends RefCounted

var current_test: String = ""
var failure_count: int = 0
var total_failures: int = 0

var _suite_name: String = "unknown"


func setup() -> void:
	pass


func teardown() -> void:
	pass


# --- Helpers for accessing autoload singletons ------------------------------

func event_bus() -> Node:
	return _root().get_node("EventBus")


func resource_manager() -> Node:
	return _root().get_node("ResourceManager")


func pool_manager() -> Node:
	return _root().get_node("PoolManager")


## Adds [param node] to the tree for the duration of a test and returns it.
func stage(node: Node) -> Node:
	_root().add_child(node)
	return node


func unstage(node: Node) -> void:
	if is_instance_valid(node) and node.is_inside_tree():
		_root().remove_child(node)


# --- Assertions ---------------------------------------------------------------

func assert_true(condition: bool, context: String = "") -> void:
	if not condition:
		fail("expected true %s" % context)


func assert_false(condition: bool, context: String = "") -> void:
	if condition:
		fail("expected false %s" % context)


func assert_eq(expected: Variant, actual: Variant, context: String = "") -> void:
	if expected != actual:
		fail("%s | expected '%s' but got '%s'" % [context, str(expected), str(actual)])


func assert_ne(unexpected: Variant, actual: Variant, context: String = "") -> void:
	if unexpected == actual:
		fail("%s | did not expect '%s'" % [context, str(actual)])


func assert_almost_eq(expected: float, actual: float, epsilon: float, context: String = "") -> void:
	if absf(expected - actual) > epsilon:
		fail("%s | expected %.4f +/- %.4f but got %.4f" % [context, expected, epsilon, actual])


func assert_null(value: Variant, context: String = "") -> void:
	if value != null:
		fail("%s | expected null but got '%s'" % [context, str(value)])


func assert_not_null(value: Variant, context: String = "") -> void:
	if value == null:
		fail("%s | expected non-null" % context)


func fail(message: String) -> void:
	failure_count += 1
	total_failures += 1
	printerr("    FAIL [%s.%s] %s" % [_suite_name, current_test, message])


# --- Internal -----------------------------------------------------------------

func begin_test(suite_name: String, test_name: String) -> void:
	_suite_name = suite_name
	current_test = test_name
	failure_count = 0


func _root() -> Node:
	var main_loop := Engine.get_main_loop()
	return (main_loop as SceneTree).root
