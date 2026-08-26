## Central registry for data-driven definitions (SPEC-0001).
##
## Gameplay systems must never load resource files directly; they ask this
## registry instead. Registration validates each definition and refuses any
## resource with validation errors, keeping invalid content out of runtime.
##
## Registered as the "ResourceManager" autoload; intentionally no class_name.
extends Node

var _resources: Dictionary = {}


## Validates and registers a definition. Returns false when the resource is
## null, fails validation errors, or its id is already taken.
func register(resource: GameResource) -> bool:
	if resource == null:
		push_error("ResourceManager.register: resource is null")
		return false
	var report: Dictionary = resource.validate()
	var errors: PackedStringArray = report.errors
	for error: String in errors:
		push_error("ResourceManager: rejected '%s' (%s): %s" % [resource.id, resource.resource_path, error])
	if not errors.is_empty():
		return false
	if _resources.has(resource.id):
		push_error("ResourceManager: duplicate id '%s'" % resource.id)
		return false
	var warnings: PackedStringArray = report.warnings
	for warning: String in warnings:
		push_warning("ResourceManager: '%s' %s" % [resource.id, warning])
	_resources[resource.id] = resource
	return true


func has(resource_id: String) -> bool:
	return _resources.has(resource_id)


## Returns the definition for [param resource_id], or null when unknown.
## Silent by design: optional content lookups must not spam the log;
## use require() when absence indicates a bug.
func get_by_id(resource_id: String) -> GameResource:
	return _resources.get(resource_id)


## Like get_by_id() but logs an error when the id is missing.
func require(resource_id: String) -> GameResource:
	var resource: GameResource = _resources.get(resource_id)
	if resource == null:
		push_error("ResourceManager.require: unknown id '%s'" % resource_id)
	return resource


## All registered definitions of one category ("enemy.goblin.basic" -> "enemy").
func get_category(category_name: String) -> Array[GameResource]:
	var result: Array[GameResource] = []
	for resource: GameResource in _resources.values():
		if resource.category() == category_name:
			result.append(resource)
	return result


func count() -> int:
	return _resources.size()


## Removes every registration. Used between test cases and full reloads.
func clear() -> void:
	_resources.clear()
