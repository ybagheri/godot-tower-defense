## Validates and executes tower construction, upgrades and selling
## (SPEC-0007 placement/economy integration, SPEC-0010 purchase flow).
##
## UI never touches the wallet directly: it calls try_build/request_upgrade/
## request_sell, and this system validates payment before acting.
class_name BuildingSystem
extends RefCounted

## Placement tuning (world units); map geometry arrives with stage scenes.
const PATH_CLEARANCE: float = 46.0
const TOWER_SPACING: float = 56.0

var wallet: EconomySystem = null
var balance: BalanceDefinition = null
var spawn_parent: Node = null
var candidate_provider: Callable = Callable()
## Routes enemies walk; towers may not stand on them.
var protected_routes: Array[PathDefinition] = []

var _towers: Array[GameEntity] = []


func built_towers() -> Array[GameEntity]:
	return _towers.duplicate()


func tower_count() -> int:
	return _towers.size()


## Returns {"ok": bool, "reason": String}.
func check_placement(definition: TowerDefinition, position: Vector2) -> Dictionary:
	if definition == null:
		return {"ok": false, "reason": "invalid_definition"}
	if wallet == null or not wallet.can_afford(definition.cost):
		return {"ok": false, "reason": "insufficient_gold"}
	for route in protected_routes:
		if _distance_to_polyline(position, route.waypoints) < PATH_CLEARANCE:
			return {"ok": false, "reason": "on_path"}
	for tower in _towers:
		if is_instance_valid(tower) and tower.position.distance_to(position) < TOWER_SPACING:
			return {"ok": false, "reason": "too_close_to_tower"}
	return {"ok": true, "reason": ""}


func try_build(definition: TowerDefinition, position: Vector2) -> GameEntity:
	var check := check_placement(definition, position)
	if not check.ok:
		return null
	if not wallet.spend(definition.cost):
		return null
	var tower := TowerFactory.create(definition, position, candidate_provider, spawn_parent)
	if tower == null:
		push_error("BuildingSystem: factory failed after payment")
		wallet.add(definition.cost)
		return null
	_towers.append(tower)
	return tower


## Applies the next upgrade if affordable. Returns true on success.
func request_upgrade(tower: GameEntity) -> bool:
	if tower == null or not is_instance_valid(tower):
		return false
	var upgrades: UpgradeComponent = tower.get_component(UpgradeComponent)
	if upgrades == null or upgrades.is_max_level():
		return false
	var cost := upgrades.next_upgrade_cost()
	if not wallet.spend(cost):
		return false
	var attack: AttackComponent = tower.get_component(AttackComponent)
	if not upgrades.apply_next(attack):
		wallet.add(cost)
		push_error("BuildingSystem: upgrade application failed")
		return false
	EventBus.publish(GameEvents.TOWER_UPGRADED,
			{"entity": tower, "level": upgrades.level})
	return true


## Removes a tower and refunds part of its investment (SPEC-0010).
## Returns the refunded amount (-1 when the tower is unknown).
func request_sell(tower: GameEntity) -> int:
	if tower == null or not is_instance_valid(tower) or not _towers.has(tower):
		return -1
	var upgrades: UpgradeComponent = tower.get_component(UpgradeComponent)
	var invested := upgrades.investment if upgrades != null else 0
	var refund := int(floor(invested * (balance.sell_refund_ratio if balance != null else 0.7)))
	_towers.erase(tower)
	tower.deactivate()
	tower.queue_free()
	wallet.add(refund)
	EventBus.publish(GameEvents.TOWER_SOLD, {"entity": tower, "refund": refund})
	return refund


func _distance_to_polyline(point: Vector2, points: PackedVector2Array) -> float:
	var best := INF
	for i: int in range(points.size() - 1):
		best = minf(best, _distance_to_segment(point, points[i], points[i + 1]))
	return best


func _distance_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var segment := b - a
	var length_sq := segment.length_squared()
	if length_sq <= 0.0001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(a + segment * t)
