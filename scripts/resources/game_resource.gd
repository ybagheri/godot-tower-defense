## Base class for all data-driven gameplay definitions (SPEC-0001).
##
## Resources describe content; they never execute gameplay logic.
## Every definition carries a permanent, lowercase, dotted identifier and a
## version for future migrations.
##
## Subclasses override validate() to append their own rules, always merging
## the result of the base implementation.
class_name GameResource
extends Resource

@export var id: String = ""
@export var version: int = 1
## Localization key shown in UI (SPEC-0013); falls back to display_name.
@export var display_key: String = ""
## Editor-facing fallback name when no translation is available yet.
@export var display_name: String = ""


## Returns {"errors": PackedStringArray, "warnings": PackedStringArray}.
## Errors block registration; warnings only log.
func validate() -> Dictionary:
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	if id.is_empty():
		errors.append("Missing resource id")
	elif not _is_id_valid(id):
		errors.append("Invalid id '%s': must be lowercase, no spaces (category.type.name recommended)" % id)
	if version <= 0:
		errors.append("Invalid version %d: must be >= 1" % version)
	if display_key.is_empty() and display_name.is_empty():
		warnings.append("'%s' has neither display_key nor display_name" % id)
	return {"errors": errors, "warnings": warnings}


## Category segment of the id ("enemy.goblin.basic" -> "enemy").
func category() -> String:
	var dot := id.find(".")
	if dot < 0:
		return id
	return id.substr(0, dot)


static func _is_id_valid(candidate: String) -> bool:
	if candidate != candidate.to_lower():
		return false
	for character: String in [" ", "\t", "\n", "/"]:
		if candidate.contains(character):
			return false
	return true
