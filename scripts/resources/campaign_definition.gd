## Ordered stages of one campaign (SPEC-0011).
##
## Unlock rule: entry 0 is always available; any later entry requires every
## earlier stage to hold at least one recorded star (sequential gating).
class_name CampaignDefinition
extends GameResource

@export var entries: Array[StageEntryDefinition] = []


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if entries.is_empty():
		errors.append("%s: campaign needs at least one stage" % id)
	var seen := {}
	for entry: StageEntryDefinition in entries:
		errors.append_array(entry.validate(id))
		if entry.stage != null:
			if seen.has(entry.stage.id):
				errors.append("%s: duplicate stage '%s'" % [id, entry.stage.id])
			seen[entry.stage.id] = true
	return report


## Sequential unlock gate against a {"stage_id": stars} snapshot.
static func is_entry_unlocked(campaign: CampaignDefinition, index: int,
		stars_by_stage: Dictionary) -> bool:
	if campaign == null or index < 0 or index >= campaign.entries.size():
		return false
	for i in index:
		var stage_def: StageDefinition = campaign.entries[i].stage
		if int(stars_by_stage.get(stage_def.id, 0)) < 1:
			return false
	return true
