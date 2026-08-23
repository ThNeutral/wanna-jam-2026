class_name BaseWeapon
extends Node2D

var index: int = -1
func set_index(new_value: int):
	index = new_value

static var _index_to_key: Dictionary[int, Key] = {
	0: KEY_1,
	1: KEY_2,
	2: KEY_3,
	3: KEY_4,
}

@export var super_cooldown: float = 3.0
var super_counter: float

var _is_active = false
func set_is_active(new_value: bool) -> void:
	_is_active = new_value

func on_added(
	_initial_position: Vector2,
	_initial_rotation: float
) -> void:
	assert(false, "on_added was not overwritten")

func _direction_to_cursor(pos = global_position) -> Vector2:
	return (get_global_mouse_position() - pos).normalized()

func _process(delta: float) -> void:
	_handle_super(delta)

func _handle_super(delta: float) -> void:
	if not _is_active:
		return
	
	var key = _index_to_key.get(index)
	assert(key != null, "index was not set")
	
	super_counter += delta
	if super_counter > super_cooldown and Input.is_key_pressed(key):
		super_counter = 0
		_invoke_super()

func _invoke_super() -> void:
	assert(false, "_invoke_super was not overwritten")
