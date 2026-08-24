extends BaseWeapon

@export var damage: int

@export var attack_delay: float
var attack_counter = 0
var _is_in_attack = false

@export var rotation_speed: float
@export var attack_length: float
var attack_length_counter: float

var is_in_super: bool = false

@export var maximum_rotation_angle: float
var initial_rotation: float
func _minimal_rotation() -> float:
	return initial_rotation - deg_to_rad(maximum_rotation_angle)
func _maximum_rotation() -> float:
	return initial_rotation + deg_to_rad(maximum_rotation_angle)

@export var super_length: float
var super_length_counter: float

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	initial_rotation = rotation
	rotation = _minimal_rotation()
	set_is_active(true)

func _ready() -> void:
	$HeadArea.visible = false
	$HeadArea.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	super._process(delta)
	_handle_rotate_to_mouse(delta)

func _physics_process(delta: float) -> void:
	_handle_rotation(delta)

func _handle_rotation(delta: float) -> void:	
	if not _is_active or is_in_super:
		return
	
	if not _is_in_attack:
		attack_counter += delta
	
	if attack_counter < attack_delay:
		return
	
	if not _is_in_attack:
		_handle_start_attack()
	
	attack_length_counter += delta
	var t = min(1.0, 1.0 - (attack_length - attack_length_counter) / attack_length)
	var target = _maximum_rotation()
	rotation = lerp_angle(
		rotation,
		target,
		t
	)
	
	if t == 1.0:
		_handle_end_attack()

func _handle_start_attack():
	rotation = _minimal_rotation()
	_is_in_attack = true
	$HeadArea.visible = true
	var areas = $HeadArea.get_overlapping_areas()
	for area in areas:
		_on_area_entered(area)

func _handle_end_attack():
	_is_in_attack = false
	$HeadArea.visible = false
	attack_counter = 0
	attack_length_counter = 0
	rotation = initial_rotation

func _handle_rotate_to_mouse(delta: float) -> void:
	if not _is_active or _is_in_attack or is_in_super:
		return
	
	var direction = _direction_to_cursor($HandleEnd.global_position)
	var t = 1.0 - exp(-deg_to_rad(rotation_speed) * delta)
	var target = direction.angle() + deg_to_rad(maximum_rotation_angle)
	rotation = lerp_angle(
		rotation,
		target,
		t
	)
	initial_rotation = rotation

func _handle_rotate_super(delta: float) -> void:
	if not _is_active or not _is_in_attack or not is_in_super:
		return
	
	super_length_counter += delta
	var t = 1.0 - (super_length - super_length_counter) / super_length
	var target = initial_rotation + 2 * PI
	rotation = lerp_angle(
		rotation,
		target,
		t
	)
	
func _invoke_super() -> void:
	is_in_super = true

func _on_area_entered(area: Area2D) -> void:
	if not _is_active or not _is_in_attack:
		return
	
	if area.name == "EnemyCollider":
		var enemy = area.get_parent() as Enemy
		enemy.receive_damage(damage)

func _handle_damage(enemy: Enemy) -> void:
	enemy.receive_damage(damage)
