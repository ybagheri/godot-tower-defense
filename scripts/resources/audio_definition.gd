## One playable sound: stream, category bus, volume and limiting (SPEC-0014).
class_name AudioDefinition
extends GameResource

@export var stream_path: String = ""
## Audio bus name; must match default_bus_layout.tres.
@export_enum("Music", "Effects", "UI", "Ambient") var bus_category: String = "Effects"
@export var volume_db: float = 0.0
## Same sound will not retrigger within this window (sound limiting).
@export var min_interval_ms: int = 45


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if stream_path.is_empty() or not ResourceLoader.exists(stream_path):
		errors.append("%s: missing or empty stream_path '%s'" % [id, stream_path])
	return report
