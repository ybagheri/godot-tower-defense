## HUD controller: displays state, forwards intents to BattleController.
##
## Contains NO gameplay logic. Every button routes through controller
## intents; every label updates from EventBus events or controller queries.
class_name HudController
extends CanvasLayer

@onready var gold_label: Label = %GoldLabel
@onready var wave_label: Label = %WaveLabel
@onready var castle_bar: ProgressBar = %CastleBar
@onready var enemies_label: Label = %EnemiesLabel
@onready var speed_button: Button = %SpeedButton
@onready var pause_button: Button = %PauseButton
@onready var build_bar: HBoxContainer = %BuildBar
@onready var ability_bar: HBoxContainer = %AbilityBar
@onready var selection_panel: PanelContainer = %SelectionPanel
@onready var selection_title: Label = %SelectionTitle
@onready var selection_stats: Label = %SelectionStats
@onready var upgrade_button: Button = %UpgradeButton
@onready var sell_button: Button = %SellButton
@onready var result_overlay: CenterContainer = %ResultOverlay
@onready var result_label: Label = %ResultLabel
@onready var restart_button: Button = %RestartButton
@onready var toast_label: Label = %ToastLabel

@export var controller: BattleController

var _build_buttons: Dictionary = {}
var _ability_buttons: Dictionary = {}
var _toast_until_ms: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	result_overlay.visible = false
	selection_panel.visible = false
	toast_label.visible = false


## Called by the BattleController after it resolves scene wiring. Children
## become ready before their parent, so the controller binds us explicitly.
func bind_controller(new_controller: BattleController) -> void:
	controller = new_controller

	EventBus.subscribe(GameEvents.CURRENCY_CHANGED, _on_currency_changed)
	EventBus.subscribe(GameEvents.WAVE_STARTED, _on_wave_started)
	EventBus.subscribe(GameEvents.WAVE_COMPLETED, _on_wave_completed)
	EventBus.subscribe(GameEvents.CASTLE_DAMAGED, _on_castle_damaged)
	EventBus.subscribe(GameEvents.SHOW_NOTIFICATION, _on_notification)

	speed_button.pressed.connect(_on_speed_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	restart_button.pressed.connect(_restart)

	controller.build_mode_changed.connect(_on_build_mode_changed)
	controller.selection_changed.connect(_on_selection_changed)
	controller.battle_ended.connect(announce_result)

	_build_bar_for_catalog()
	_build_ability_bar()
	castle_bar.max_value = controller.castle_max_health()
	castle_bar.value = controller.castle_current_health()
	_on_currency_changed({"gold": controller.wallet.gold})
	_update_speed_button()
	_update_pause_button()
	_refresh_wave_line()


func _process(_delta: float) -> void:
	_refresh_wave_line()
	_refresh_ability_buttons()
	enemies_label.text = tr("UI_ENEMIES_FORMAT").format([controller.registry.count()])
	if toast_label.visible and Time.get_ticks_msec() >= _toast_until_ms:
		toast_label.visible = false


func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvents.CURRENCY_CHANGED, _on_currency_changed)
	EventBus.unsubscribe(GameEvents.WAVE_STARTED, _on_wave_started)
	EventBus.unsubscribe(GameEvents.WAVE_COMPLETED, _on_wave_completed)
	EventBus.unsubscribe(GameEvents.CASTLE_DAMAGED, _on_castle_damaged)
	EventBus.unsubscribe(GameEvents.SHOW_NOTIFICATION, _on_notification)


func announce_result(victory: bool) -> void:
	result_label.text = tr("UI_VICTORY") if victory else tr("UI_DEFEAT")
	if victory:
		var stars := controller.saved_stage_stars(controller.stage.id)
		result_label.text += "\n" + tr("UI_STARS_FORMAT").format([stars])
	result_overlay.visible = true


# --- Build bar ---------------------------------------------------------------

func _build_bar_for_catalog() -> void:
	for definition in controller.tower_catalog:
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 72)
		button.pressed.connect(_on_build_button_pressed.bind(definition))
		build_bar.add_child(button)
		_build_buttons[definition.id] = button
	_refresh_build_buttons()


func _refresh_build_buttons() -> void:
	for definition in controller.tower_catalog:
		var button: Button = _build_buttons.get(definition.id)
		if button == null:
			continue
		var armed: bool = controller.is_build_armed() \
				and controller.armed_definition() == definition
		var title: String = tr(definition.display_key) \
				if definition.display_key != "" else definition.display_name
		button.text = "{0}\n{1} g{2}".format([
			title, definition.cost, " <<" if armed else "",
		])
		button.disabled = not armed and not controller.wallet.can_afford(definition.cost)


# --- Ability bar ---------------------------------------------------------------

func _build_ability_bar() -> void:
	for definition in controller.ability_system().definitions:
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 60)
		button.pressed.connect(_on_ability_button_pressed.bind(definition))
		ability_bar.add_child(button)
		_ability_buttons[definition.id] = button


func _refresh_ability_buttons() -> void:
	var system := controller.ability_system()
	for definition in system.definitions:
		var button: Button = _ability_buttons.get(definition.id)
		if button == null:
			continue
		var remaining := int(ceil(system.cooldown_remaining(definition)))
		var title: String = tr(definition.display_key) \
				if definition.display_key != "" else definition.display_name
		var armed: bool = system.armed_ability() == definition
		button.text = "{0}{1}\n{2}".format([
			title,
			" <<" if armed else "",
			tr("UI_READY") if remaining <= 0 else "{0}s".format([remaining]),
		])
		var affordable: bool = definition.gold_cost <= 0 \
				or controller.wallet.can_afford(definition.gold_cost)
		button.disabled = armed or remaining > 0 or not affordable


func _on_ability_button_pressed(definition: AbilityDefinition) -> void:
	if controller.ability_system().armed_ability() == definition:
		controller.ability_system().cancel_arm()
	else:
		controller.arm_ability(definition)
	_refresh_ability_buttons()


# --- Event reactions ----------------------------------------------------------

func _on_currency_changed(payload: Dictionary) -> void:
	gold_label.text = tr("UI_GOLD_FORMAT").format([int(payload.get("gold", 0))])
	_refresh_build_buttons()
	_refresh_selection_panel()


func _on_wave_started(payload: Dictionary) -> void:
	if bool(payload.get("is_boss", false)):
		_show_toast(tr("UI_BOSS_WARNING"))
	_refresh_wave_line()


func _on_wave_completed(_payload: Dictionary) -> void:
	_refresh_wave_line()


func _on_castle_damaged(payload: Dictionary) -> void:
	castle_bar.max_value = int(payload.get("max", 1))
	castle_bar.value = int(payload.get("current", 0))


func _on_notification(payload: Dictionary) -> void:
	_show_toast(str(payload.get("message", "")))


# --- Button intents -------------------------------------------------------------

func _on_speed_pressed() -> void:
	controller.cycle_speed()
	_update_speed_button()


func _on_pause_pressed() -> void:
	controller.toggle_pause()
	_update_pause_button()


func _on_upgrade_pressed() -> void:
	if not controller.upgrade_selected():
		_show_toast(tr("UI_CANNOT_UPGRADE"))
	_refresh_selection_panel()
	_refresh_build_buttons()


func _on_sell_pressed() -> void:
	var refund := controller.sell_selected()
	if refund >= 0:
		_show_toast(tr("UI_SOLD_FORMAT").format([refund]))
		_refresh_build_buttons()


func _on_build_button_pressed(definition: TowerDefinition) -> void:
	if controller.is_build_armed() and controller.armed_definition() == definition:
		controller.cancel_building()
	else:
		controller.arm_building(definition)
	_refresh_build_buttons()


func _on_build_mode_changed(_armed: bool) -> void:
	_refresh_build_buttons()


func _on_selection_changed(_tower: GameEntity) -> void:
	_refresh_selection_panel()


# --- Refresh helpers -----------------------------------------------------------

func _refresh_wave_line() -> void:
	if controller.waves.state == WaveSystem.State.PREPARING:
		wave_label.text = tr("UI_PREPARING_FORMAT").format([
			int(ceil(controller.waves.preparation_seconds_remaining())),
			controller.waves.current_wave_number,
			controller.stage.waves.size(),
		])
	elif controller.waves.state == WaveSystem.State.IDLE:
		wave_label.text = "-"
	else:
		wave_label.text = tr("UI_WAVE_FORMAT").format([
			controller.waves.current_wave_number,
			controller.stage.waves.size(),
		])


func _refresh_selection_panel() -> void:
	var tower := controller.selected_tower()
	if tower == null or not is_instance_valid(tower):
		selection_panel.visible = false
		return
	var upgrades: UpgradeComponent = tower.get_component(UpgradeComponent)
	var attack: AttackComponent = tower.get_component(AttackComponent)
	if upgrades == null or attack == null:
		selection_panel.visible = false
		return
	selection_panel.visible = true
	var title_name: String = tr(upgrades.tower_definition.display_key) \
			if upgrades.tower_definition.display_key != "" \
			else upgrades.tower_definition.display_name
	selection_title.text = "{0} - {1} {2}".format([
		title_name, tr("UI_LEVEL"), upgrades.level,
	])
	selection_stats.text = tr("UI_TOWER_STATS_FORMAT").format([
		attack.attack_damage, int(attack.attack_range), "%.1f" % attack.attack_speed,
	])
	if upgrades.is_max_level():
		upgrade_button.text = tr("UI_MAX_LEVEL")
		upgrade_button.disabled = true
	else:
		upgrade_button.text = "{0} ({1} g)".format([
			tr("UI_UPGRADE"), upgrades.next_upgrade_cost(),
		])
		upgrade_button.disabled = not controller.wallet.can_afford(upgrades.next_upgrade_cost())
	sell_button.text = "{0} (+{1} g)".format([tr("UI_SELL"),
			int(floor(upgrades.investment * controller.balance.sell_refund_ratio))])


func _update_speed_button() -> void:
	speed_button.text = "x{0}".format([int(controller.speed_multiplier())])


func _update_pause_button() -> void:
	pause_button.text = tr("UI_RESUME") if controller.is_paused() else tr("UI_PAUSE")


func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = message != ""
	_toast_until_ms = Time.get_ticks_msec() + 2000


func _restart() -> void:
	get_tree().reload_current_scene()
