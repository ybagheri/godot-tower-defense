## One-shot expanding ring burst used for deaths, arrivals and ability
## detonations. Pooled through PoolManager (ARCH-0001); pure presentation.
class_name BurstEffect
extends Node2D

var color: Color = Color.ORANGE
var start_radius: float = 6.0
var end_radius: float = 40.0
var lifetime: float = 0.35

var _age: float = 0.0


func configure(burst_color: Color, from_radius: float, to_radius: float,
		duration: float) -> void:
	color = burst_color
	start_radius = from_radius
	end_radius = to_radius
	lifetime = maxf(duration, 0.05)
	_age = 0.0
	queue_redraw()


func advance(delta: float) -> void:
	if _age >= lifetime:
		return
	_age += delta
	if _age >= lifetime:
		retire()
	else:
		queue_redraw()


func retire() -> void:
	_age = lifetime
	if has_meta(PoolManager.META_POOL_KEY):
		PoolManager.release(self)
	elif is_inside_tree():
		queue_free()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	var t := clampf(_age / lifetime, 0.0, 1.0)
	var radius := lerpf(start_radius, end_radius, t)
	var alpha := 1.0 - t
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40,
			Color(color.r, color.g, color.b, alpha * 0.8), 3.0)
	if t < 0.4:
		draw_circle(Vector2.ZERO, start_radius * (1.0 - t * 2.0),
				Color(color.r, color.g, color.b, alpha * 0.5))
