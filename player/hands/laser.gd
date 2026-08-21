extends BaseWeapon

@export var damage: int

@export var rotation_speed_degrees: float

@export var shoot_delay: float
@export var shoot_length: float
var shoot_counter: float
var is_shooting: bool = false

var shoot_length_counter: float

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	set_is_active(true)

func _ready() -> void:
	_switch_shooting_state(false)
	$Ray/RayCollider.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	_handle_shoot(delta)

func _physics_process(delta: float) -> void:
	_handle_rotate(delta)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var direction = _direction_to_cursor($RayStart.global_position)
	var t = 1.0 - exp(-deg_to_rad(rotation_speed_degrees) * delta)
	var target = direction.angle()
	global_rotation = lerp_angle(
		global_rotation,
		target,
		t
	)

func _handle_shoot(delta: float) -> void:
	if not _is_active:
		return
	
	if is_shooting:
		_handle_active_fire(delta)
	else:
		_handle_cooldown(delta)

func _handle_active_fire(delta: float) -> void:
	shoot_counter += delta
	if shoot_counter > shoot_length:
		_switch_shooting_state(false)
	
func _handle_cooldown(delta: float) -> void:
	shoot_counter += delta
	if shoot_counter > shoot_delay:
		_switch_shooting_state(true)

func _switch_shooting_state(new_value: bool) -> void:
	$Ray.visible = new_value
	shoot_counter = 0
	is_shooting = new_value
	if is_shooting:
		var areas = $Ray/RayCollider.get_overlapping_areas()
		for area in areas:
			_on_area_entered(area)

func _on_area_entered(area: Area2D):
	if area.name == "EnemyCollider":
		var enemy = area.get_parent() as Enemy
		enemy.receive_damage(damage)
