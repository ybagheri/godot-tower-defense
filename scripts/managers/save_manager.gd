## Versioned player-data persistence (SPEC-0012).
##
## JSON at user://save/save_001.json with a top-level version; loading
## validates the version, migrates when needed (v1 is the baseline), and
## recovers from corrupt files by quarantining them and starting fresh.
##
## Registered as the "SaveManager" autoload; intentionally no class_name
## (an autoload name cannot also be a global class).
extends Node

const SAVE_PATH: String = "user://save/save_001.json"
const CURRENT_VERSION: int = 1

var data: Dictionary = {}


func _ready() -> void:
	load_game()


## Collects [param section] under a stable key, replacing prior content.
func store_section(section_name: String, content: Dictionary) -> void:
	data[section_name] = content


func get_section(section_name: String) -> Dictionary:
	return data.get(section_name, {})


func save_game() -> bool:
	data["version"] = CURRENT_VERSION
	DirAccess.make_dir_recursive_absolute(SAVE_PATH.get_base_dir())
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot write %s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func load_game() -> bool:
	data = {}
	if not FileAccess.file_exists(SAVE_PATH):
		data = _fresh_data()
		return true
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: cannot read save; starting fresh")
		data = _fresh_data()
		return false
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_warning("SaveManager: corrupt save quarantined")
		_quarantine_corrupt()
		data = _fresh_data()
		return false

	var loaded: Dictionary = parsed
	var version := int(loaded.get("version", -1))
	if version < 1 or version > CURRENT_VERSION:
		push_warning("SaveManager: unsupported save version %d" % version)
		data = _fresh_data()
		return false
	data = migrate(loaded, version)
	return true


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	data = _fresh_data()


## Migration chain hook. Each step upgrades one version; the baseline v1
## passes through untouched. Extend with `match` arms as versions grow.
func migrate(loaded: Dictionary, from_version: int) -> Dictionary:
	match from_version:
		CURRENT_VERSION:
			return loaded
		_:
			push_error("SaveManager: no migration path from version %d" % from_version)
			return _fresh_data()


func reset_to_fresh() -> void:
	data = _fresh_data()


func _fresh_data() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"progression": {"stages": {}},
		"settings": {},
		"statistics": {},
	}


func _quarantine_corrupt() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var backup := SAVE_PATH + ".corrupt"
		DirAccess.copy_absolute(SAVE_PATH, backup)
		DirAccess.remove_absolute(SAVE_PATH)
