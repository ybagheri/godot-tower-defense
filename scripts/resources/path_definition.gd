## Waypoint route definition (SPEC-0009).
##
## A path tells WHERE to go; the MovementComponent decides HOW. The final
## waypoint is the destination (castle gate). Paths are shared resources:
## many enemies reference the same instance, no per-frame recalculation.
class_name PathDefinition
extends GameResource

enum PathType { GROUND, FLYING }

@export var waypoints: PackedVector2Array = PackedVector2Array()
@export var path_type: PathType = PathType.GROUND


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if waypoints.size() < 2:
		errors.append("%s: a path needs at least 2 waypoints" % id)
	return report


func first_waypoint() -> Vector2:
	return waypoints[0]


func destination() -> Vector2:
	return waypoints[waypoints.size() - 1]


func waypoint_count() -> int:
	return waypoints.size()


## Total polyline length; useful for debugging and future progress UI.
func total_length() -> float:
	var length := 0.0
	for i: int in range(1, waypoints.size()):
		length += waypoints[i - 1].distance_to(waypoints[i])
	return length
