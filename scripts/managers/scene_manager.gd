## Scene navigation and cross-scene handoff (intended global service).
##
## Holds only a stage PATH (never live objects) between scenes so the menu
## can hand a selection to the battle scene without global game state.
extends Node

const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/game/battle.tscn"

var _pending_stage_path: String = ""


## Queues a stage for the next battle scene load; navigation happens here.
func open_stage(stage_path: String) -> void:
	_pending_stage_path = stage_path
	get_tree().change_scene_to_file(BATTLE_SCENE)


func return_to_menu() -> void:
	_pending_stage_path = ""
	get_tree().change_scene_to_file(MENU_SCENE)


## Battle scenes call this once at startup; returns "" when nothing queued.
func consume_pending_stage() -> String:
	var path := _pending_stage_path
	_pending_stage_path = ""
	return path


## Test seam: queue without navigating.
func queue_stage(stage_path: String) -> void:
	_pending_stage_path = stage_path
