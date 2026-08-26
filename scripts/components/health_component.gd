## Tracks health state and announces death exactly once (SPEC-0003/0006).
##
## Receives FINAL damage values only: mitigation math belongs to the
## CombatSystem, never here. Local signals serve future UI bars; the global
## entity_died event lets unrelated systems (rewards, waves, quests) react.
class_name HealthComponent
extends GameComponent

signal health_changed(current_health: int, max_health: int)
signal died

var max_health: int = 1
var current_health: int = 1

var _death_announced: bool = false


## Configures (or resets) the health pool. Marks the entity alive again,
## which keeps pooled entities reusable across battles.
func configure(new_max_health: int) -> void:
	max_health = maxi(new_max_health, 1)
	current_health = max_health
	_death_announced = false


func is_alive() -> bool:
	return current_health > 0


## Applies post-mitigation damage. Returns the amount actually removed.
func receive_damage(amount: int) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var applied := mini(amount, current_health)
	current_health -= applied
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		_announce_death()
	return applied


func heal(amount: int) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var applied := mini(amount, max_health - current_health)
	current_health += applied
	health_changed.emit(current_health, max_health)
	return applied


func _announce_death() -> void:
	if _death_announced:
		return
	_death_announced = true
	died.emit()
	var entity := get_entity()
	EventBus.publish(GameEvents.ENTITY_DIED, {"entity": entity})
