## Reward information carried by killable entities (SPEC-0008 LootComponent).
##
## State only: converting loot into currency is RewardSystem's job.
class_name LootComponent
extends GameComponent

var reward_gold: int = 0
## Damage dealt to the castle when the enemy reaches the destination.
var damage_to_castle: int = 1


func configure(new_reward_gold: int, new_damage_to_castle: int) -> void:
	reward_gold = new_reward_gold
	damage_to_castle = new_damage_to_castle
