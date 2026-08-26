## Runtime gameplay object composed of components (SPEC-0002).
##
## An entity owns its lifecycle and its components; it contains no gameplay
## rules of its own. Components are attached either as child nodes in a scene
## (auto-registered on ready) or programmatically through add_component().
##
## One component instance per component script is allowed per entity; the
## script acts as the capability key for get_component().
class_name GameEntity
extends Node2D

enum State { CREATED, ACTIVE, DISABLED, DESTROYED }

@export var entity_id: String = ""
@export var tags: PackedStringArray = []

var state: State = State.CREATED

var _components: Dictionary = {}


func _ready() -> void:
	# Children are ready before their parent, so scene-authored components
	# can be discovered safely here.
	_register_child_components()
	_setup_components()
	activate()


## Programmatically attaches a component. Refuses duplicates of the same
## component script (the incoming node is freed to avoid leaks).
func add_component(component: GameComponent) -> bool:
	if component == null:
		push_error("GameEntity.add_component: component is null")
		return false
	var key: Script = component.get_script()
	if key == null:
		push_error("GameEntity.add_component: component has no script")
		component.free()
		return false
	if _components.has(key):
		push_error("GameEntity '%s' already has component %s" % [entity_id, key.get_global_name()])
		component.free()
		return false
	add_child(component)
	component._bind(self)
	_components[key] = component
	component.on_setup()
	if state == State.ACTIVE:
		component.on_activated()
	return true


## Returns the component implementing [param type] (a component script), or null.
func get_component(type: Script) -> GameComponent:
	var component: GameComponent = _components.get(type)
	return component


func has_component(type: Script) -> bool:
	return _components.has(type)


## Removes and frees a previously added component.
func remove_component(component: GameComponent) -> void:
	if component == null or not _components.has(component.get_script()):
		push_warning("GameEntity.remove_component: unknown component")
		return
	_components.erase(component.get_script())
	component.on_removed()
	remove_child(component)
	component.free()


## Moves from CREATED/DISABLED into ACTIVE, activating all components.
func activate() -> void:
	if state == State.ACTIVE or state == State.DESTROYED:
		return
	state = State.ACTIVE
	for component: GameComponent in _components.values():
		component.on_activated()


## Deactivates without destroying; used by pause-like flows.
func deactivate() -> void:
	if state != State.ACTIVE:
		return
	state = State.DISABLED
	for component: GameComponent in _components.values():
		component.on_deactivated()


## Tears down components and marks the entity DESTROYED.
##
## Memory rules: inside the tree the node is queued for deletion; outside the
## tree the node only tears down state and the CALLER owns freeing it (a node
## cannot synchronously free itself while one of its methods is executing).
## Pooled entities rely on this contract: they are torn down here and returned
## to their pool instead of being freed.
func destroy() -> void:
	if state == State.DESTROYED:
		return
	for component: GameComponent in _components.values():
		component.on_removed()
	_components.clear()
	state = State.DESTROYED
	if is_inside_tree():
		queue_free()


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func add_tag(tag: String) -> void:
	if not tags.has(tag):
		tags.append(tag)


func remove_tag(tag: String) -> void:
	tags.remove_at(tags.find(tag))


func _register_child_components() -> void:
	for child in get_children():
		if child is GameComponent:
			var component := child as GameComponent
			var key: Script = component.get_script()
			if key == null:
				push_error("GameEntity '%s': child component without script" % entity_id)
				continue
			if _components.has(key):
				continue
			component._bind(self)
			_components[key] = component


func _setup_components() -> void:
	for component: GameComponent in _components.values():
		component.on_setup()
