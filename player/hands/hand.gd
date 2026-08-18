class_name Hand
extends Node2D

@export var allowed_rotation_angle: float
@export var rotation_speed: float
var initial_rotation
func _get_minimal_rotation() -> float:
	return initial_rotation - deg_to_rad(allowed_rotation_angle)
func _get_maximal_rotation() -> float:
	return initial_rotation + deg_to_rad(allowed_rotation_angle)

func _ready() -> void:
	initial_rotation = rotation

func _physics_process(delta: float) -> void:
	_handle_rotation(delta) 

func _handle_rotation(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_angle = (global_position - mouse_pos).angle()
	rotation = clamp(
		_get_minimal_rotation(),
		_lerp(delta, mouse_angle),
		_get_maximal_rotation()
	)

func _lerp(delta: float, target_rotation: float) -> float:
	var t = 1.0 - exp(-deg_to_rad(rotation_speed) * delta)
	return 	lerp_angle(rotation, target_rotation, t)

func _linear(delta: float, target_rotation: float) -> float:
	return rotate_toward(rotation, target_rotation, delta * deg_to_rad(rotation_speed))
