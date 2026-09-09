class_name Player
extends Node2D

signal died

@export var speed: float

@export var zoom_limits: Vector2 = Vector2(0.1, 5.0)
@export var initial_zoom: float = 1.0
@export var zoom_step: float

@export var total_health: int

var shield: int
var received_damage: int = 0

var _handles: Array[Node2D] = []
var _camera: Camera2D

func _ready() -> void:
	_camera = $Camera as Camera2D
	
	_handles.append($Mounts/MountRT)
	_handles.append($Mounts/MountLT)
	_handles.append($Mounts/MountRB)
	_handles.append($Mounts/MountLB)
	
	_set_zoom(initial_zoom)

func current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return current_health() <= 0

func receive_damage(amount: int) -> void:
	if is_dead():
		return
	
	if shield > 0:
		shield = max(0, shield - amount)
		return
	
	received_damage += amount
	if is_dead():
		died.emit()

func add_weapon(weapon: BaseWeapon) -> bool:
	var index := _get_empty_handle_index()
	if index == -1:
		return false
	
	weapon.reparent(_handles[index])
	weapon.position = Vector2.ZERO
	weapon.rotation = 0.0
	weapon.set_index(index)
	weapon.on_added()
	return true

func _process(delta: float) -> void:
	_handle_pan_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_zoom_in"):
		_set_zoom(_camera.zoom.x + zoom_step)
	elif event.is_action_pressed(&"camera_zoom_out"):
		_set_zoom(_camera.zoom.x - zoom_step)

func _set_zoom(value: float) -> void:
	var clamped := clampf(value, zoom_limits.x, zoom_limits.y)
	_camera.zoom = Vector2(clamped, clamped)

func _handle_pan_camera(delta: float) -> void:
	var direction := Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down"
	)
	position += direction * speed * delta

func _get_empty_handle_index() -> int:
	for index in _handles.size():
		if _handles[index].get_child_count() == 0:
			return index
	
	return -1
