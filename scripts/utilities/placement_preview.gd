## Placement feedback: ghost visual + live range circle with validity tint
## while a tower build is armed (§21 readability).
##
## Pure presentation driven by the controller; performs no validation of its
## own beyond reading check results.
class_name PlacementPreview
extends Node2D

const VALID_COLOR := Color(0.55, 0.9, 0.45, 0.6)
const INVALID_COLOR := Color(0.95, 0.3, 0.25, 0.7)

var controller: BattleController = null

var _ghost: Node2D = null
var _armed_id: String = ""
var _last_valid: bool = false


func _process(_delta: float) -> void:
	if controller == null or not is_instance_valid(controller):
		visible = false
		return
	var definition := controller.armed_definition()
	if definition == null:
		_clear_ghost()
		visible = false
		return

	visible = true
	position = get_global_mouse_position()

	if _armed_id != definition.id:
		_rebuild_ghost(definition)

	var result: Dictionary = controller.placement_result_for(position)
	_last_valid = bool(result.ok)
	if _ghost != null:
		_ghost.modulate = Color(1, 1, 1, 0.55) if _last_valid \
				else Color(1.0, 0.4, 0.35, 0.5)
	queue_redraw()


func _draw() -> void:
	if not visible or controller == null:
		return
	var definition := controller.armed_definition()
	if definition == null:
		return
	var ring_color := VALID_COLOR if _last_valid else INVALID_COLOR
	draw_arc(Vector2.ZERO, definition.attack_range, 0.0, TAU, 64, ring_color, 2.5)
	draw_circle(Vector2.ZERO, 8.0,
			Color(ring_color.r, ring_color.g, ring_color.b, ring_color.a))


func _rebuild_ghost(definition: TowerDefinition) -> void:
	_clear_ghost()
	_armed_id = definition.id
	if definition.visual_scene != null:
		_ghost = definition.visual_scene.instantiate() as Node2D
		if _ghost != null:
			add_child(_ghost)


func _clear_ghost() -> void:
	if _ghost != null and is_instance_valid(_ghost):
		_ghost.free()
	_ghost = null
	_armed_id = ""
