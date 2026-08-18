class_name Player
extends Node2D

@export var player: Node2D
@export var camera: Camera2D

@export var camera_speed: float

@export var total_health: int
var received_damage: int = 0
func _current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return _current_health() <= 0

func receive_damage(damage: int):
	received_damage += damage

var pan_camera_controls: Dictionary[Key, Vector2] = {
	KEY_W: Vector2.UP,
	KEY_S: Vector2.DOWN,
	KEY_A: Vector2.LEFT,
	KEY_D: Vector2.RIGHT,
}

func _process(delta: float) -> void:
	_handle_pan_camera(delta)
	
func _handle_pan_camera(delta: float) -> void: 
	var direction = Vector2.ZERO
	for key in pan_camera_controls.keys():
		if Input.is_key_pressed(key as Key):
			direction += pan_camera_controls[key]
	
	position += direction * camera_speed * delta
