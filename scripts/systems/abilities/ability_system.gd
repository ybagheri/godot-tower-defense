## Executes player abilities: targeting mode, costs, cooldowns, effects
## (SPEC-0015).
##
## Mirrors the WaveSystem determinism pattern: all timing flows through
## advance(delta) (also wired to _process), so tests simulate casts without
## waiting frames. Presentation is delegated through an injected vfx_hook.
class_name AbilitySystem
extends Node

var wallet: EconomySystem = null
var registry: EnemyRegistry = null
## Callable(effect_type: int, position: Vector2, radius: float)
var vfx_hook: Callable = Callable()
var definitions: Array[AbilityDefinition] = []

var _cooldowns: Dictionary = {}
var _armed: AbilityDefinition = null
var _pending_impacts: Array[Dictionary] = []
var _pending_unfreezes: Array[Dictionary] = []


func setup(catalog: Array[AbilityDefinition], economy: EconomySystem,
		enemies: EnemyRegistry) -> void:
	definitions = catalog
	wallet = economy
	registry = enemies


func arm(definition: AbilityDefinition) -> void:
	if definition == null or is_on_cooldown(definition):
		return
	_armed = definition


func cancel_arm() -> void:
	_armed = null


func armed_ability() -> AbilityDefinition:
	return _armed


func is_on_cooldown(definition: AbilityDefinition) -> bool:
	return float(_cooldowns.get(definition.id, 0.0)) > 0.0


func cooldown_remaining(definition: AbilityDefinition) -> float:
	return float(_cooldowns.get(definition.id, 0.0))


## Player taps the world while an ability is armed.
func try_cast_at(position: Vector2) -> bool:
	if _armed == null or is_on_cooldown(_armed):
		return false
	if wallet != null and not wallet.spend(_armed.gold_cost):
		return false
	var definition := _armed
	_armed = null
	_cooldowns[definition.id] = definition.cooldown_seconds
	EventBus.publish(GameEvents.ABILITY_CAST_STARTED,
			{"ability_id": definition.id, "position": position})
	EventBus.publish(GameEvents.SHOW_NOTIFICATION, {})

	match definition.effect_type:
		AbilityDefinition.EffectType.AREA_DAMAGE:
			_pending_impacts.append({
				"time_left": definition.cast_delay_seconds,
				"definition": definition,
				"position": position,
			})
		AbilityDefinition.EffectType.FREEZE:
			_apply_freeze(definition, position)
			EventBus.publish(GameEvents.ABILITY_EXECUTED,
					{"ability_id": definition.id, "position": position})
	return true


func advance(delta: float) -> void:
	for key: StringName in _cooldowns.keys():
		if float(_cooldowns[key]) > 0.0:
			_cooldowns[key] = maxf(0.0, float(_cooldowns[key]) - delta)

	var i := 0
	while i < _pending_impacts.size():
		var impact: Dictionary = _pending_impacts[i]
		impact.time_left = float(impact.time_left) - delta
		if float(impact.time_left) <= 0.0:
			_detonate(impact.definition, impact.position)
			_pending_impacts.remove_at(i)
		else:
			i += 1

	var j := 0
	while j < _pending_unfreezes.size():
		var entry: Dictionary = _pending_unfreezes[j]
		entry.time_left = float(entry.time_left) - delta
		if float(entry.time_left) <= 0.0:
			_restore(entry)
			_pending_unfreezes.remove_at(j)
		else:
			j += 1


func is_frozen(enemy: GameEntity) -> bool:
	for entry: Dictionary in _pending_unfreezes:
		if entry.entity == enemy:
			return true
	return false


func _detonate(definition: AbilityDefinition, position: Vector2) -> void:
	var hits := 0
	for enemy in registry.get_enemies():
		if enemy.position.distance_to(position) <= definition.radius:
			hits += 1
			CombatSystem.resolve_hit(enemy, null, definition.damage,
					definition.damage_type)
	EventBus.publish(GameEvents.ABILITY_EXECUTED,
			{"ability_id": definition.id, "position": position, "hits": hits})
	if vfx_hook.is_valid():
		vfx_hook.call("explosion", position, definition.radius)


func _apply_freeze(definition: AbilityDefinition, position: Vector2) -> void:
	for enemy in registry.get_enemies():
		if enemy.position.distance_to(position) > definition.radius:
			continue
		var movement: MovementComponent = enemy.get_component(MovementComponent)
		if movement == null or movement.is_frozen():
			continue
		movement.set_frozen(true)
		_pending_unfreezes.append({
			"time_left": definition.freeze_duration,
			"entity": enemy,
			"movement": movement,
		})
	if vfx_hook.is_valid():
		vfx_hook.call("frost", position, definition.radius)


func _restore(entry: Dictionary) -> void:
	var movement: MovementComponent = entry.movement
	if movement != null and is_instance_valid(movement):
		movement.set_frozen(false)


func _process(delta: float) -> void:
	advance(delta)
