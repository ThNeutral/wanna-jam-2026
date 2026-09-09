extends BaseWeapon

@export var damage: int

@export var attack_delay: float
@export var attack_length: float

@export var super_stun_length: float = 1.5

@export var rotation_speed: float
@export var maximum_rotation_angle: float

var _attack_counter: float
var _attack_length_counter: float
var _is_in_attack: bool = false
var _rest_rotation: float

func on_added() -> void:
	_rest_rotation = rotation
	rotation = _minimal_rotation()
	set_is_active(true)

func _ready() -> void:
	$HeadArea.visible = false
	($HeadArea as Area2D).area_entered.connect(_on_area_entered)

func _update(delta: float) -> void:
	_handle_rotate_to_mouse(delta)

func _physics_process(delta: float) -> void:
	if is_in_super:
		_handle_rotate_super()
	else:
		_handle_attack(delta)

func _minimal_rotation() -> float:
	return _rest_rotation - deg_to_rad(maximum_rotation_angle)

func _maximum_rotation() -> float:
	return _rest_rotation + deg_to_rad(maximum_rotation_angle)

func _handle_attack(delta: float) -> void:
	if not _is_active:
		return
	
	if not _is_in_attack:
		_attack_counter += delta
		if _attack_counter < attack_delay:
			return
		
		_start_attack()
	
	_attack_length_counter += delta
	var t := clampf(_attack_length_counter / attack_length, 0.0, 1.0) if attack_length > 0.0 else 1.0
	rotation = lerp_angle(rotation, _maximum_rotation(), t)
	
	if t >= 1.0:
		_end_attack()

func _handle_rotate_to_mouse(delta: float) -> void:
	if not _is_active or _is_in_attack or is_in_super:
		return
	
	var target := _direction_to_cursor($HandleEnd.global_position).angle() + deg_to_rad(maximum_rotation_angle)
	var t := 1.0 - exp(-deg_to_rad(rotation_speed) * delta)
	rotation = lerp_angle(rotation, target, t)
	_rest_rotation = rotation

func _handle_rotate_super() -> void:
	if not _is_active:
		return
	
	rotation = _rest_rotation + TAU * super_progress()

func _on_super_started() -> void:
	_start_attack()

func _on_super_ended() -> void:
	_end_attack()

func _start_attack() -> void:
	_is_in_attack = true
	_attack_length_counter = 0.0
	rotation = _minimal_rotation()
	$HeadArea.visible = true
	
	for area in ($HeadArea as Area2D).get_overlapping_areas():
		_on_area_entered(area)

func _end_attack() -> void:
	_is_in_attack = false
	_attack_counter = 0.0
	_attack_length_counter = 0.0
	$HeadArea.visible = false
	rotation = _rest_rotation

func _on_area_entered(area: Area2D) -> void:
	if not _is_active or not _is_in_attack:
		return
	
	var enemy := Combat.enemy_of(area)
	if enemy != null:
		if is_in_super:
			enemy.apply_stun(super_stun_length)
		
		enemy.receive_damage(damage)
