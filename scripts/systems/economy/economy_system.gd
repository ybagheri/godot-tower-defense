## Gold storage and spending validation (SPEC-0010).
##
## Pure value logic with no node dependencies: UI sends intents through
## gameplay systems which call spend()/add(); direct wallet mutation from
## UI is prohibited by the architecture.
class_name EconomySystem
extends RefCounted

signal gold_changed(new_gold: int)

var gold: int = 0


func configure(starting_gold: int) -> void:
	gold = maxi(starting_gold, 0)
	_announce()


func can_afford(cost: int) -> bool:
	return cost >= 0 and gold >= cost


## Removes [param cost] when affordable. Returns false (and changes nothing)
## otherwise; negative costs are rejected as invalid input.
func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	gold -= cost
	_announce()
	return true


func add(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	_announce()


func _announce() -> void:
	gold_changed.emit(gold)
	EventBus.publish(GameEvents.CURRENCY_CHANGED, {"gold": gold})
