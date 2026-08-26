## Headless test entry point (runs with autoloads active).
##
## Usage:
##   godot --headless --path . res://tests/test_runner.tscn
##
## Discovers every res://tests/unit/*_test.gd suite, executes its test_*
## methods alphabetically, prints per-suite results, and exits 1 on failure.
extends Node


func _ready() -> void:
	# Deferred so suites run after scene setup finishes; otherwise adding
	# nodes to the root during _ready fails ("parent node is busy").
	_run.call_deferred()


func _run() -> void:
	var failed_suites: PackedStringArray = []
	var suites := _discover_suites()
	for path: String in suites:
		var suite_script: GDScript = load(path)
		if suite_script == null:
			failed_suites.append(path)
			printerr("  [BROKEN] could not load %s" % path)
			continue
		if not _run_suite(path.get_file(), suite_script):
			failed_suites.append(path)

	print("--------------------------------------------------")
	if failed_suites.is_empty():
		print("ALL SUITES PASSED")
		get_tree().quit(0)
	else:
		printerr("FAILED SUITES: %s" % ", ".join(failed_suites))
		get_tree().quit(1)


func _discover_suites() -> PackedStringArray:
	var names := PackedStringArray()
	var directory := DirAccess.open("res://tests/unit")
	if directory == null:
		printerr("Cannot open res://tests/unit")
		return names
	for file: String in directory.get_files():
		if file.ends_with("_test.gd"):
			names.append(file)
	names.sort()
	var paths := PackedStringArray()
	for file: String in names:
		paths.append("res://tests/unit/" + file)
	return paths


func _run_suite(file_name: String, suite_script: GDScript) -> bool:
	var suite: TestSuite = suite_script.new()
	var suite_name := file_name.trim_suffix(".gd")
	var ran_tests: int = 0

	var methods := PackedStringArray()
	for info: Dictionary in suite.get_method_list():
		var method_name: String = info.name
		if method_name.begins_with("test_"):
			methods.append(method_name)
	methods.sort()

	print("[SUITE] %s (%d tests)" % [suite_name, methods.size()])
	for method: String in methods:
		suite.begin_test(suite_name, method)
		suite.setup()
		suite.call(method)
		suite.teardown()
		if suite.failure_count == 0:
			print("    ok   %s" % method)
		else:
			printerr("    FAIL %s (%d assertion failures)" % [method, suite.failure_count])
		ran_tests += 1

	var passed := suite.total_failures == 0
	if passed:
		print("  [PASS] %s: %d tests passed" % [suite_name, ran_tests])
	else:
		printerr("  [FAIL] %s: %d total assertion failures" % [suite_name, suite.total_failures])
	return passed
