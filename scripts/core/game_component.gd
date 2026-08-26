## Base class for all reusable gameplay capabilities (SPEC-0003).
##
## Components own state, expose small capabilities, and emit events. They do
## not manage unrelated systems or contain whole-feature gameplay rules; that
## belongs to Systems operating on top of them.
##
## Lifecycle hooks are called exclusively by the owning GameEntity:
## on_setup -> on_activated -> (on_deactivated <-> on_activated) -> on_removed.
class_name GameComponent
extends Node

var enabled: bool = true


## Owning entity, assigned during attachment. Null while unattached.
##
## Deliberately typed as Node2D instead of GameEntity: GameEntity already
## depends on GameComponent, and a reverse static reference would create a
## cyclic class dependency which is unreliable in Godot's loader. Cast where
## full entity access is required: `component.get_entity() as GameEntity`.
var _entity: Node2D = null


func get_entity() -> Node2D:
	return _entity


## Called by GameEntity during attachment. Not part of the public lifecycle.
func _bind(entity: Node2D) -> void:
	_entity = entity


func is_enabled() -> bool:
	return enabled


func set_enabled(value: bool) -> void:
	enabled = value


# --- Lifecycle hooks (extension points overridden by concrete components) --


## Called once after attachment to an entity. Initialize state here.
func on_setup() -> void:
	pass


## Called when the owning entity becomes active (also right after setup if
## the entity was already active). Start processing here.
func on_activated() -> void:
	pass


## Called when the owning entity is deactivated (pause-like flows).
func on_deactivated() -> void:
	pass


## Called exactly once before the component stops being used.
func on_removed() -> void:
	pass
