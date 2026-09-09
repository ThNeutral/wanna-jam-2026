class_name BaseWeapon
extends Node2D

const SUPER_ACTIONS: Array[StringName] = [
	&"weapon_super_1",
	&"weapon_super_2",
	&"weapon_super_3",
	&"weapon_super_4",
]

@export var has_super: bool = true
@export var super_cooldown: float = 3.0
@export var super_length: float = 1.0

var index: int = -1
var is_in_super: bool = false

var _is_active: bool = false
var _cooldown_counter: float
var _super_counter: float

func set_index(new_value: int) -> void:
	index = new_value

func set_is_active(new_value: bool) -> void:
	_is_active = new_value

func on_added() -> void:
	set_is_active(true)

func super_progress() -> float:
	if super_length <= 0.0:
		return 1.0
	
	return clampf(_super_counter / super_length, 0.0, 1.0)

func _process(delta: float) -> void:
	_handle_super(delta)
	_update(delta)

func _update(_delta: float) -> void:
	pass

func _direction_to_cursor(from: Vector2 = global_position) -> Vector2:
	return from.direction_to(get_global_mouse_position())

func _handle_super(delta: float) -> void:
	if not _is_active or not has_super:
		return
	
	if is_in_super:
		_super_counter += delta
		if _super_counter >= super_length:
			_end_super()
		return
	
	if index < 0 or index >= SUPER_ACTIONS.size():
		assert(false, "index was not set")
		return
	
	_cooldown_counter += delta
	if _cooldown_counter > super_cooldown and Input.is_action_pressed(SUPER_ACTIONS[index]):
		_start_super()

func _start_super() -> void:
	_cooldown_counter = 0.0
	_super_counter = 0.0
	is_in_super = true
	_on_super_started()

func _end_super() -> void:
	_super_counter = 0.0
	is_in_super = false
	_on_super_ended()

func _on_super_started() -> void:
	pass

func _on_super_ended() -> void:
	pass
