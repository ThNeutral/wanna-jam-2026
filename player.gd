extends Node2D

@export var player: Node2D
@export var camera: Camera2D

@export var camera_speed: float

var pan_camera_controls: Dictionary[Key, Vector2] = {
	KEY_W: Vector2.UP,
	KEY_S: Vector2.DOWN,
	KEY_A: Vector2.LEFT,
	KEY_D: Vector2.RIGHT,
}

func _process(delta: float) -> void:
	_handle_pan_camera(delta)
	_handle_rotate_body()
	pass
	
func _handle_rotate_body() -> void:
	player.look_at(get_global_mouse_position())
	
func _handle_pan_camera(delta: float) -> void: 
	var direction = Vector2.ZERO
	for key in pan_camera_controls.keys():
		if Input.is_key_pressed(key as Key):
			direction += pan_camera_controls[key]
	
	var angle_to_mouse = (get_global_mouse_position() - position).angle()
	direction = direction.rotated(angle_to_mouse + PI / 2)
	
	position += direction * camera_speed * delta
