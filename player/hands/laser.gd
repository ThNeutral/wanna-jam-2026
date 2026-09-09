extends BaseWeapon

@export var rotation_speed_degrees: Vector2
@export var damage: Vector2
@export var scale_ray: float

@export var shoot_delay: float
@export var shoot_length: float

var _shoot_counter: float
var _is_shooting: bool = false

func _ready() -> void:
	($Ray/RayCollider as Area2D).area_entered.connect(_on_area_entered)
	_switch_shooting_state(false)

func _update(delta: float) -> void:
	_handle_shoot(delta)

func _physics_process(delta: float) -> void:
	_handle_rotate(delta)

func _on_super_started() -> void:
	_scale_ray(scale_ray)

func _on_super_ended() -> void:
	_scale_ray(1.0)

func _current_rotation_speed() -> float:
	return rotation_speed_degrees.y if is_in_super else rotation_speed_degrees.x

func _current_damage() -> int:
	return int(damage.y if is_in_super else damage.x)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var target := _direction_to_cursor($RayStart.global_position).angle()
	var t := 1.0 - exp(-deg_to_rad(_current_rotation_speed()) * delta)
	global_rotation = lerp_angle(global_rotation, target, t)

func _handle_shoot(delta: float) -> void:
	if not _is_active:
		return
	
	_shoot_counter += delta
	if _is_shooting:
		if _shoot_counter > shoot_length:
			_switch_shooting_state(false)
	elif _shoot_counter > shoot_delay:
		_switch_shooting_state(true)

func _switch_shooting_state(new_value: bool) -> void:
	$Ray.visible = new_value
	_shoot_counter = 0.0
	_is_shooting = new_value
	
	if not _is_shooting:
		return
	
	for area in ($Ray/RayCollider as Area2D).get_overlapping_areas():
		_on_area_entered(area)

func _on_area_entered(area: Area2D) -> void:
	if not _is_shooting:
		return
	
	var enemy := Combat.enemy_of(area)
	if enemy != null:
		enemy.receive_damage(_current_damage())

func _scale_ray(factor: float) -> void:
	$Ray/RaySprite.scale.y = factor
	$Ray/RayCollider/CollisionShape2D.scale.y = factor
