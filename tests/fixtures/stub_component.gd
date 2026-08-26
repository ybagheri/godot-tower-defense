## Test fixture component recording lifecycle hook invocations.
class_name StubComponent
extends GameComponent

var setup_calls: int = 0
var activated_calls: int = 0
var deactivated_calls: int = 0
var removed_calls: int = 0


func on_setup() -> void:
	setup_calls += 1


func on_activated() -> void:
	activated_calls += 1


func on_deactivated() -> void:
	deactivated_calls += 1


func on_removed() -> void:
	removed_calls += 1
