## Pooled chasing projectile delivering a pre-committed attack (SPEC-0006).
##
## The projectile only transports an attack request; all mitigation happens
## inside CombatSystem at impact time using the TARGET's current stats.
## Retires back into the PoolManager when it was acquired from one.
class_name Projectile
extends Node2D

const ARRIVE_DISTANCE: float = 4.0

var _target: GameEntity = null
var _speed: float = 600.0
var _attack: Dictionary = {}


func launch(from_position: Vector2, target: GameEntity, speed: float, attack: Dictionary) -> void:
	position = from_position
	_target = target
	_speed = maxf(speed, 1.0)
	_attack = attack


func is_in_flight() -> bool:
	return _target != null


func advance(delta: float) -> void:
	if _target == null:
		return
	if not is_instance_valid(_target):
		_retire(false)
		return
	var to_target := _target.position - position
	var step := _speed * delta
	if to_target.length() <= maxf(step, ARRIVE_DISTANCE):
		position = _target.position
		_impact()
	else:
		position += to_target.normalized() * step


func _impact() -> void:
	CombatSystem.resolve_hit(_target, _attack.get("attacker"), _attack.get("damage", 0),
			_attack.get("type", DamageTypes.Type.PHYSICAL), _attack.get("crit_chance", 0.0),
			_attack.get("crit_mult", 2.0))
	_retire(true)


## [param hit_landed] distinguishes a real impact from a lost-target expiry;
## both stop flight, only callers care about the difference for effects later.
func _retire(hit_landed: bool) -> void:
	_target = null
	if has_meta(PoolManager.META_POOL_KEY):
		PoolManager.release(self)
	elif is_inside_tree():
		queue_free()
		set_process(false)


func _process(delta: float) -> void:
	advance(delta)
