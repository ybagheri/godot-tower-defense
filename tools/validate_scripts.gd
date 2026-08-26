## Loads every .gd under res://scripts to force full compilation.
##
## Usage:
##   godot --headless --path . -s tools/validate_scripts.gd
##
## Exits 1 when any script fails to compile (parse/type errors).
extends SceneTree


func _initialize() -> void:
	var failures := PackedStringArray()
	var checked: int = _scan("res://scripts", failures)
	if failures.is_empty():
		print("VALIDATION OK: %d scripts compiled" % checked)
		quit(0)
	else:
		for failure: String in failures:
			printerr(failure)
		printerr("VALIDATION FAILED: %d of %d scripts broken" % [failures.size(), checked])
		quit(1)


func _scan(directory_path: String, failures: PackedStringArray) -> int:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		failures.append("cannot open %s" % directory_path)
		return 0
	var count: int = 0
	for entry: String in directory.get_files():
		if entry.ends_with(".gd"):
			count += 1
			var path := directory_path + "/" + entry
			if ResourceLoader.load(path, "GDScript") == null:
				failures.append("%s: failed to compile" % path)
	for subdirectory: String in directory.get_directories():
		count += _scan(directory_path + "/" + subdirectory, failures)
	return count
