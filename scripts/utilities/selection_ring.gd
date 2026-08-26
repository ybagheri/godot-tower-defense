## Draws gameplay readability aids around the selected tower (§21).
##
## Shows the attack range circle; pure presentation, no logic.
class_name SelectionRing
extends Node2D

const RING_SEGMENTS: int = 48

var radius: float = 0.0


func follow(tower: GameEntity) -> void:
	if tower == null or not is_instance_valid(tower):
		radius = 0.0
	else:
		var targeting: TargetingComponent = tower.get_component(TargetingComponent)
		radius = targeting.range_px if targeting != null else 0.0
	position = tower.position if radius > 0.0 else Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	if radius <= 0.0:
		return
	var points := PackedVector2Array()
	for i: int in RING_SEGMENTS + 1:
		var angle := TAU * float(i) / float(RING_SEGMENTS)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(points, Color(1.0, 0.9, 0.5, 0.55), 2.0)
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.9, 0.5, 0.35))
