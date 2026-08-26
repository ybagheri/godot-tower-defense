## Main menu: campaign stage select with stars and unlock gating.
##
## UI layer only: reads persistent progression, sends navigation intents to
## the SceneManager. No gameplay logic lives here.
class_name MainMenu
extends Control

@export var campaign: CampaignDefinition

@onready var stage_list: VBoxContainer = %StageList
@onready var quit_button: Button = %QuitButton

var _save_manager: Node = null


func _ready() -> void:
	_save_manager = get_node_or_null("/root/SaveManager")
	_build_stage_buttons()
	quit_button.visible = not OS.has_feature("web")
	quit_button.pressed.connect(func() -> void:
		get_tree().quit())


func _stars_by_stage() -> Dictionary:
	if _save_manager == null:
		return {}
	return _save_manager.get_section("progression").get("stages", {})


func _build_stage_buttons() -> void:
	for child in stage_list.get_children():
		child.queue_free()
	var stars := _stars_by_stage()
	for i in campaign.entries.size():
		var entry := campaign.entries[i]
		var unlocked := CampaignDefinition.is_entry_unlocked(campaign, i, stars)
		var button := Button.new()
		button.custom_minimum_size = Vector2(560, 76)
		var title: String = tr(entry.stage.display_key) \
				if entry.stage.display_key != "" else entry.stage.display_name
		var recorded := int(stars.get(entry.stage.id, 0))
		var star_line := ""
		for s in 3:
			star_line += "*" if s < recorded else "."
		button.text = "{0}.  {1}   {2}".format([i + 1, title, star_line]) \
				if unlocked else "{0}.  {1}".format([i + 1, tr("UI_LOCKED")])
		button.disabled = not unlocked
		button.pressed.connect(_on_stage_pressed.bind(entry.stage.resource_path))
		stage_list.add_child(button)


func _on_stage_pressed(stage_path: String) -> void:
	var router := get_node_or_null("/root/SceneManager")
	if router != null:
		router.open_stage(stage_path)
