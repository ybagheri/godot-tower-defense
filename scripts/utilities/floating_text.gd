## Pooled rising text for damage and gold feedback (§21 readability).
##
## Event-driven through BattleVfx; capped by the pool so heavy waves cannot
## flood the screen or the allocator.
class_name FloatingText
extends Node2D

const RISE_DISTANCE: float = 34.0

var lifetime: float = 0.7

var _age: float = 0.0
var _label: Label = null


func configure(text: String, color: Color) -> void:
	if _label == null:
		_label = Label.new()
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.add_theme_font_size_override("font_size", 15)
		_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		_label.add_theme_constant_override("outline_size", 4)
		add_child(_label)
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	_age = 0.0
	position = position + Vector2(randf_range(-8.0, 8.0), -18.0)
	modulate.a = 1.0
	queue_redraw()


func advance(delta: float) -> void:
	if _age >= lifetime:
		return
	_age += delta
	var t := clampf(_age / lifetime, 0.0, 1.0)
	_label.position.y = -RISE_DISTANCE * t if _label != null else 0.0
	modulate.a = 1.0 - t * t
	if _age >= lifetime:
		retire()


func retire() -> void:
	_age = lifetime
	if has_meta(PoolManager.META_POOL_KEY):
		PoolManager.release(self)
	elif is_inside_tree():
		queue_free()
	var layer := get_meta(&"vfx_layer", null) as Node
	if layer != null and is_instance_valid(layer):
		layer.notify_text_retired()


func _process(delta: float) -> void:
	advance(delta)
