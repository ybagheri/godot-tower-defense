## One playable slot inside a campaign (SPEC-0011 campaign progression).
class_name StageEntryDefinition
extends Resource

@export var stage: StageDefinition = null


func validate(context_id: String) -> PackedStringArray:
	var errors := PackedStringArray()
	if stage == null:
		errors.append("%s: stage entry missing StageDefinition" % context_id)
	elif stage.map_scene == null:
		errors.append("%s: '%s' has no map_scene and cannot ship" % [context_id, stage.id])
	return errors
