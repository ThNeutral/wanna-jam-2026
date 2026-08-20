class_name BaseWeapon
extends Node2D

var _is_active = false
func set_is_active(new_value: bool) -> void:
	_is_active = new_value

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	pass

func _direction_to_cursor(pos = global_position) -> Vector2:
	return (get_global_mouse_position() - pos).normalized()
