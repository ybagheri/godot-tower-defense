## Headless performance harness: saturates the gameplay loop and reports
## frame timings (§23 "measure first").
##
## Run:
##   godot --headless --path . res://tools/stress_battle.tscn -- enemy_count=150 tower_count=15 frames=400
##
## Measures LOGIC cost only (headless skips rendering); device GPU profiling
## remains part of REL-0001 verification.
extends Node

var enemy_count := 120
var tower_count := 12
var frames_to_sample := 360


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var parts := arg.split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"enemy_count":
				enemy_count = int(parts[1])
			"tower_count":
				tower_count = int(parts[1])
			"frames":
				frames_to_sample = int(parts[1])
	_build_battle()


func _build_battle() -> void:
	var definition := EnemyDefinition.new()
	definition.id = "enemy.stress.dummy"
	definition.display_name = "Stress Dummy"
	definition.max_health = 25
	definition.speed = 90.0
	definition.reward_gold = 1
	ResourceManager.register(definition)

	var container := Node2D.new()
	add_child(container)
	var relay := EnemyEventRelay.new()
	add_child(relay)

	var route := PathDefinition.new()
	var points := PackedVector2Array()
	for i in 9:
		points.append(Vector2(60 + i * 140, 200 + (280 if i % 2 == 1 else 0)))
	route.waypoints = points

	for t in tower_count:
		var archer := TowerDefinition.new()
		archer.id = "tower.stress.archer%d" % t
		archer.attack_damage = 8
		archer.attack_speed = 2.0
		archer.attack_range = 190.0
		archer.cost = 0
		var tower := TowerFactory.create(archer,
				Vector2(120 + (t % 6) * 180, 340 + (t / 6) * 90),
				Callable(), container)
		if tower == null:
			push_error("stress tower failed")

	for e in enemy_count:
		var enemy := EnemyFactory.create(definition, route, null)
		enemy.position = route.first_waypoint() + Vector2(e * 3 % 800, randf_range(-14, 14))
		container.add_child(enemy)

	print("[Stress] enemies=%d towers=%d sampling %d frames..." %
			[enemy_count, tower_count, frames_to_sample])
	set_process(true)


var _sampled := 0
var _elapsed := 0.0
var _worst := 0.0


func _process(delta: float) -> void:
	if _sampled >= frames_to_sample:
		return
	# Skip engine warmup frames before sampling begins.
	if _elapsed == 0.0 and _sampled == 0 and Engine.get_process_frames() < 30:
		return
	_elapsed += delta
	_worst = maxf(_worst, delta * 1000.0)
	_sampled += 1
	if _sampled == frames_to_sample:
		var avg_ms := (_elapsed / frames_to_sample) * 1000.0
		print("[Stress] RESULT avg_frame=%.2fms worst=%.2fms (~%d fps logic budget)" %
				[avg_ms, _worst, int(1000.0 / maxf(avg_ms, 0.01))])
		get_tree().quit(0)
