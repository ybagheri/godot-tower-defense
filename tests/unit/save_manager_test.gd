## Tests for SaveManager persistence, versioning and corruption handling
## (SPEC-0012).
extends TestSuite

const SAVE_PATH := "user://save/save_001.json"

var manager: Node = null


func setup() -> void:
	manager = save_manager()
	manager.delete_save()


func teardown() -> void:
	manager.delete_save()


func test_fresh_save_has_expected_sections() -> void:
	var data: Dictionary = manager.data
	assert_eq(1, int(data.get("version", -1)), "version stamped")
	assert_true(data.has("progression"), "progression section exists")
	assert_true(data.has("settings"), "settings section exists")


func test_store_and_roundtrip() -> void:
	manager.store_section("progression", {"stages": {"stage.001.test_range": 3}})
	manager.store_section("statistics", {"total_kills": 120})
	assert_true(manager.save_game(), "write succeeds")
	manager.data = {}
	assert_true(manager.load_game(), "read succeeds")
	var progression: Dictionary = manager.get_section("progression")
	assert_eq(3, int(progression.get("stages", {}).get("stage.001.test_range", 0)),
			"stars persisted")


func test_corrupt_file_quarantined_and_recovered() -> void:
	manager.store_section("progression", {"stages": {"x": 1}})
	manager.save_game()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("{ this is not json !!!")
	file.close()

	assert_false(manager.load_game(), "corrupt load reports failure but recovers")
	assert_eq(1, int(manager.data.get("version", -1)), "fresh data served")
	assert_true(FileAccess.file_exists(SAVE_PATH + ".corrupt"),
			"broken file preserved for diagnosis")


func test_unknown_future_version_rejected() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 99, "progression": {}}))
	file.close()
	assert_false(manager.load_game(), "future version refused")
	assert_eq(1, int(manager.data.version), "falls back to fresh v1 data")


func test_missing_file_starts_clean() -> void:
	assert_true(manager.load_game(), "absent file is not an error")
	assert_eq(0, manager.get_section("progression").get("stages", {}).size(),
			"no stages recorded")
