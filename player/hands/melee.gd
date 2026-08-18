extends Node2D

@export var damage: int

@export var rotation_speed: float
@export var maximum_rotation_angle: float
var initial_rotation: float
func _minimal_rotation() -> float:
	return initial_rotation - deg_to_rad(maximum_rotation_angle)
func _maximum_rotation() -> float:
	return initial_rotation + deg_to_rad(maximum_rotation_angle)

var flip_direction_handled = true
var positive_direction = true

func _ready() -> void:
	initial_rotation = rotation

func _physics_process(delta: float) -> void:
	_handle_rotation(delta)

func _handle_rotation(delta: float) -> void:	
	var t = 1.0 - exp(-deg_to_rad(rotation_speed) * delta)
	var target = _maximum_rotation() if positive_direction else _minimal_rotation()
	rotation = lerp_angle(
		rotation,
		target,
		t
	)
	
	if (positive_direction and abs(rotation - _maximum_rotation()) <= 1e-1):
		positive_direction = false
		_handle_flip_direction() 
	elif (!positive_direction and abs(rotation - _minimal_rotation()) <= 1e-1):
		positive_direction = true
		_handle_flip_direction()

func _handle_flip_direction():
	var areas = $HeadArea.get_overlapping_areas()
	for area in areas:
		_on_area_entered(area)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyCollider":
		var enemy = area.get_parent() as Enemy
		enemy.receive_damage(damage)

func _handle_damage(enemy: Enemy) -> void:
	enemy.receive_damage(damage)
