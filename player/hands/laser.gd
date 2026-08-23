extends BaseWeapon

@export var rotation_speed_degrees: Vector2
func _get_rotation_speed() -> float:
	return rotation_speed_degrees.x if not is_in_super else rotation_speed_degrees.y

@export var damage: Vector2
func _get_damage() -> float:
	return damage.x if not is_in_super else damage.y

@export var scale_ray: float

@export var shoot_delay: float
@export var shoot_length: float
var shoot_counter: float
var is_shooting: bool = false

@export var super_length: float
var super_duration_counter: float
var is_in_super: bool = false

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
	super._process(delta)
	_handle_shoot(delta)
	_handle_active_super(delta)

func _physics_process(delta: float) -> void:
	_handle_rotate(delta)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var direction = _direction_to_cursor($RayStart.global_position)
	var t = 1.0 - exp(-deg_to_rad(_get_rotation_speed()) * delta)
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
		enemy.receive_damage(_get_damage())

func _handle_active_super(delta: float) -> void:
	if not _is_active or not is_in_super:
		return
	
	super_duration_counter += delta
	if super_duration_counter > super_length:
		_disable_super()

func _invoke_super() -> void:
	is_in_super = true
	_scale_ray(scale_ray)

func _disable_super() -> void:
	is_in_super = false
	_scale_ray(1)
	super_duration_counter = 0

func _scale_ray(scale: float) -> void:
	$Ray/RaySprite.scale.y = scale
	$Ray/RayCollider/CollisionShape2D.scale.y = scale
