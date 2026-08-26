## Converts gameplay events into currency rewards (SPEC-0010 reward flow).
##
## Lives on the EventBus: producers (enemies dying, waves completing) never
## know who pays the player.
class_name RewardSystem
extends Node

var _wallet: EconomySystem = null


## Must be called before the node enters the tree.
func setup(wallet: EconomySystem) -> void:
	_wallet = wallet


func _ready() -> void:
	EventBus.subscribe(GameEvents.ENEMY_DIED, _on_enemy_died)
	EventBus.subscribe(GameEvents.WAVE_COMPLETED, _on_wave_completed)


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.ENEMY_DIED, _on_enemy_died)
	EventBus.unsubscribe(GameEvents.WAVE_COMPLETED, _on_wave_completed)


func _on_enemy_died(payload: Dictionary) -> void:
	var entity: GameEntity = payload.get("entity")
	if entity == null or _wallet == null:
		return
	var loot: LootComponent = entity.get_component(LootComponent)
	if loot != null and loot.reward_gold > 0:
		_wallet.add(loot.reward_gold)
		EventBus.publish(GameEvents.GOLD_EARNED,
				{"amount": loot.reward_gold, "source": "enemy_died"})


func _on_wave_completed(payload: Dictionary) -> void:
	if _wallet == null:
		return
	var reward := int(payload.get("reward_gold", 0))
	if reward > 0:
		_wallet.add(reward)
		EventBus.publish(GameEvents.GOLD_EARNED,
				{"amount": reward, "source": "wave_completed"})
