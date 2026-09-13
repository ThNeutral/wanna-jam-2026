class_name Pause
extends Object

static var _holders: Dictionary[StringName, bool] = {}

static func hold(holder: StringName) -> void:
	_holders[holder] = true
	_apply()

static func release(holder: StringName) -> void:
	_holders.erase(holder)
	_apply()

static func release_all() -> void:
	_holders.clear()
	_apply()

static func is_held() -> bool:
	return not _holders.is_empty()

static func holders() -> Array[StringName]:
	var names: Array[StringName] = []
	names.assign(_holders.keys())
	return names

static func _apply() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.paused = not _holders.is_empty()
