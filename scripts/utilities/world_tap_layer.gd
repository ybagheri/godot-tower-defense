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
	# React ONLY to ScreenTouch presses. Both emulation flags are enabled in
	# project settings, so every desktop click arrives as a ScreenTouch too,
	# and every real finger ALSO synthesizes a mouse event: listening to both
	# would double-fire, while reading the mouse cache placed towers where the
	# PREVIOUS pointer was — coordinates were always stale at touch time.
	if event is InputEventScreenTouch and event.pressed:
		controller.handle_world_tap(world_point_for(event.position))


## Converts viewport coordinates taken FROM THE EVENT into battle-world
## coordinates. get_global_mouse_position() lags behind a fresh touch until
## the emulated mouse event is processed, mis-placing towers on Android.
func world_point_for(screen_position: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_position
