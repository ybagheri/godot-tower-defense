## Tests for BuildingSystem build/upgrade/sell flows (SPEC-0007/0010).
extends TestSuite

const StubMovementScript := preload("res://tests/fixtures/stub_component.gd")

var wallet := EconomySystem.new()
var balance := BalanceDefinition.new()
var building := BuildingSystem.new()
var archer := TowerDefinition.new()
var route := PathDefinition.new()


func setup() -> void:
	EventBus.clear(GameEvents.TOWER_BUILT)
	EventBus.clear(GameEvents.TOWER_UPGRADED)
	EventBus.clear(GameEvents.TOWER_SOLD)
	EventBus.clear(GameEvents.CURRENCY_CHANGED)

	balance = BalanceDefinition.new()
	balance.id = "balance.test"
	balance.sell_refund_ratio = 0.7

	wallet = EconomySystem.new()
	wallet.configure(500)

	archer = TowerDefinition.new()
	archer.id = "tower.archer.test"
	archer.display_name = "Archer"
	archer.cost = 100
	archer.attack_damage = 12
	archer.attack_speed = 1.2
	archer.attack_range = 260.0
	var upgrade := TowerUpgradeDefinition.new()
	upgrade.cost = 90
	upgrade.attack_damage_bonus = 10
	upgrade.attack_range_bonus = 20.0
	archer.upgrades = [upgrade]

	route = PathDefinition.new()
	route.waypoints = PackedVector2Array([Vector2(0, 0), Vector2(400, 0)])

	building = BuildingSystem.new()
	building.wallet = wallet
	building.balance = balance
	building.candidate_provider = func() -> Array: return []
	building.protected_routes = [route]


func teardown() -> void:
	EventBus.clear(GameEvents.TOWER_BUILT)
	EventBus.clear(GameEvents.TOWER_UPGRADED)
	EventBus.clear(GameEvents.TOWER_SOLD)
	EventBus.clear(GameEvents.CURRENCY_CHANGED)
	for tower in building.built_towers():
		if is_instance_valid(tower):
			tower.free()


func test_rejects_placement_on_path() -> void:
	var result: Dictionary = building.check_placement(archer, Vector2(200, 0))
	assert_false(result.ok, "path placement refused")
	assert_eq("on_path", result.reason, "reason reported")


func test_rejects_when_unaffordable() -> void:
	wallet.spend(wallet.gold)
	assert_false(building.check_placement(archer, Vector2(200, 300)).ok,
			"broke player cannot build")
	assert_null(building.try_build(archer, Vector2(200, 300)), "no tower created")


func test_build_spends_gold_and_creates_tower() -> void:
	var tower := building.try_build(archer, Vector2(200, 300))
	assert_not_null(tower, "tower built")
	assert_eq(400, wallet.gold, "cost charged")
	assert_eq(1, building.tower_count(), "tracked by system")

	var upgrades: UpgradeComponent = tower.get_component(UpgradeComponent)
	assert_eq(100, upgrades.investment, "investment starts at base cost")
	tower.free()


func test_second_tower_respects_spacing() -> void:
	assert_not_null(building.try_build(archer, Vector2(200, 300)), "first placed")
	assert_null(building.try_build(archer, Vector2(210, 310)), "too close refused")
	assert_not_null(building.try_build(archer, Vector2(330, 300)), "far enough ok")


func test_upgrade_flow_pays_and_grows_stats() -> void:
	var upgraded_events := [0]
	EventBus.subscribe(GameEvents.TOWER_UPGRADED, func(_p: Dictionary) -> void:
		upgraded_events[0] += 1)
	var tower := building.try_build(archer, Vector2(200, 300))
	var attack: AttackComponent = tower.get_component(AttackComponent)
	var upgrades: UpgradeComponent = tower.get_component(UpgradeComponent)

	assert_true(building.request_upgrade(tower), "upgrade applied")
	assert_eq(310, wallet.gold, "upgrade cost charged")
	assert_eq(22, attack.attack_damage, "damage bonus applied")
	assert_almost_eq(280.0, (tower.get_component(TargetingComponent) as TargetingComponent).range_px,
			0.001, "range bonus applied")
	assert_eq(2, upgrades.level, "level raised")
	assert_eq(190, upgrades.investment, "investment accumulated")
	assert_eq(1, upgraded_events[0], "event published")
	assert_false(building.request_upgrade(tower), "max level reached")
	tower.free()


func test_sell_refunds_ratio_and_untracks() -> void:
	var sold_payload := {}
	EventBus.subscribe(GameEvents.TOWER_SOLD, func(p: Dictionary) -> void:
		sold_payload.merge(p))
	var tower := building.try_build(archer, Vector2(200, 300))
	building.request_upgrade(tower)
	var refund := building.request_sell(tower)
	assert_eq(133, refund, "70% of 190 investment floored")
	assert_eq(443, wallet.gold, "310 remaining + 133 refund")
	assert_eq(0, building.tower_count(), "untracked")
	assert_eq(133, int(sold_payload.get("refund", -1)), "payload carries refund")


func test_sell_unknown_tower_fails_safely() -> void:
	var stranger := GameEntity.new()
	assert_eq(-1, building.request_sell(null), "null refused")
	assert_eq(-1, building.request_sell(stranger), "untracked refused")
	stranger.free()
