## Tests for EconomySystem and RewardSystem (SPEC-0010).
extends TestSuite

var wallet := EconomySystem.new()
var rewards: RewardSystem = null
var gold_events: Array[int] = []
var _last_currency_event := {}


func setup() -> void:
	EventBus.clear(GameEvents.CURRENCY_CHANGED)
	EventBus.clear(GameEvents.GOLD_EARNED)
	EventBus.clear(GameEvents.ENEMY_DIED)
	gold_events = []
	_last_currency_event = {}
	wallet = EconomySystem.new()
	wallet.gold_changed.connect(func(amount: int) -> void:
		gold_events.append(amount))
	rewards = RewardSystem.new()
	rewards.setup(wallet)


func teardown() -> void:
	EventBus.clear(GameEvents.CURRENCY_CHANGED)
	EventBus.clear(GameEvents.GOLD_EARNED)
	EventBus.clear(GameEvents.ENEMY_DIED)
	if is_instance_valid(rewards):
		unstage(rewards)
		rewards.free()


func test_wallet_starting_gold() -> void:
	wallet.configure(250)
	assert_eq(250, wallet.gold, "starting balance")
	assert_eq(1, gold_events.size(), "configure announces")


func test_spend_validates_funds() -> void:
	wallet.configure(100)
	assert_true(wallet.can_afford(100), "exact afford")
	assert_false(wallet.can_afford(101), "cannot overspend")
	assert_true(wallet.spend(60), "purchase succeeds")
	assert_eq(40, wallet.gold, "balance reduced")
	assert_false(wallet.spend(60), "insufficient refused")
	assert_eq(40, wallet.gold, "refusal changes nothing")


func test_negative_amounts_rejected() -> void:
	wallet.configure(50)
	assert_false(wallet.can_afford(-5), "negative cost invalid")
	assert_false(wallet.spend(-5), "negative spend refused")
	wallet.add(0)
	wallet.add(-10)
	assert_eq(50, wallet.gold, "no-op adds ignored")


func test_currency_changed_event_payload() -> void:
	EventBus.subscribe(GameEvents.CURRENCY_CHANGED, func(p: Dictionary) -> void:
		_last_currency_event = p.duplicate())
	wallet.configure(30)
	wallet.add(20)
	assert_eq(50, _last_currency_event.get("gold", -1), "event carries new balance")


func test_enemy_death_pays_reward() -> void:
	stage(rewards)
	var relay := EnemyEventRelay.new()
	stage(relay)
	wallet.configure(0)

	var entity := GameEntity.new()
	entity.add_tag("enemy")
	var health := HealthComponent.new()
	entity.add_component(health)
	health.configure(10)
	var loot := LootComponent.new()
	entity.add_component(loot)
	loot.configure(12, 1)
	stage(entity)

	health.receive_damage(10)
	assert_eq(12, wallet.gold, "loot converted to gold")

	var earned := {}
	EventBus.subscribe(GameEvents.GOLD_EARNED, func(p: Dictionary) -> void:
		earned = p)
	health.receive_damage(1)
	assert_true(earned.is_empty(), "corpse pays nothing twice")
	unstage(entity)
	entity.free()
	unstage(relay)
	relay.free()


func test_wave_completion_pays_bonus() -> void:
	stage(rewards)
	wallet.configure(0)
	EventBus.publish(GameEvents.WAVE_COMPLETED, {"wave_number": 3, "reward_gold": 75})
	assert_eq(75, wallet.gold, "wave bonus added")
