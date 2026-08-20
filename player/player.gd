class_name Player
extends Node2D

@export var speed: float

@export var zoom: Vector2
@export var zoom_speed: float 

@export var total_health: int
var received_damage: int = 0
func _current_health() -> int:
	return total_health - received_damage

var handles: Array[Node2D] = []
var passives: Array[Node2D] = []

func _ready() -> void:
	var current_zoom = sqrt(zoom.x + zoom.y)
	$Camera.zoom = Vector2(current_zoom, current_zoom)
	
	handles.append($Mounts/MountRT)
	handles.append($Mounts/MountLT)
	handles.append($Mounts/MountRB)
	handles.append($Mounts/MountLB)
	
	passives.append($Passives/PassiveTop)
	passives.append($Passives/PassiveMiddle)
	passives.append($Passives/PassiveBottom)

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
	_handle_zoom_camera(delta)
	
func _handle_pan_camera(delta: float) -> void: 
	var direction = Vector2.ZERO
	for key in pan_camera_controls.keys():
		if Input.is_key_pressed(key as Key):
			direction += pan_camera_controls[key]
	
	position += direction * speed * delta

func _handle_zoom_camera(delta: float) -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP)):
		print_debug("up")
	

func add_weapon(weapon: BaseWeapon)-> void:
	var handle = _get_empty_handle()
	weapon.reparent(handle)
	weapon.global_position = handle.global_position
	weapon.rotation = 0
	weapon.active = true

func add_passive(passive: Node2D) -> void:
	var passive_slot = _get_empty_passive()
	passive.reparent(passive_slot)
	passive.global_position = passive_slot.global_position
	passive.active = true

func _get_empty_handle()-> Node2D:
	for handle in handles:
		if handle.get_child_count() == 0:
			return handle
	
	return null

func _get_empty_passive()-> Node2D:
	for passive in passives:
		if passive.get_child_count() == 0:
			return passive
	
	return null
