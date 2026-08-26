## Converts screen taps into world-space intents for the BattleController.
##
## Sits above the map, below the HUD: UI consumes its own touches first
## (Controls handle input before _unhandled_input), so world taps only fire
## on empty battlefield space.
class_name WorldTapLayer
extends Node2D

@export var controller: BattleController


func _unhandled_input(event: InputEvent) -> void:
	if controller == null:
		return
	var pressed := false
	if event is InputEventScreenTouch and event.pressed:
		pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressed = true
	if pressed:
		controller.handle_world_tap(get_global_mouse_position())
