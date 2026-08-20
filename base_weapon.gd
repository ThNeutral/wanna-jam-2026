class_name BaseWeapon
extends Node2D

var is_active = false

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	pass

func _direction_to_cursor(pos = global_position) -> Vector2:
	return (get_global_mouse_position() - pos).normalized()
