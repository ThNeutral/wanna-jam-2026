extends BaseWeapon

@export var bullet_speed: float
@export var shoot_delay: float
var shoot_counter: float

@export var damage: int
@export var spread_degrees: float

@export var rotation_speed_degrees: float

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	initial_rotation = rotation
	set_is_active(true)

func _process(delta: float) -> void:
	_handle_fire(delta)
	_handle_rotate(delta)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var direction = _direction_to_cursor($BarrelEnd.global_position)
	var t = 1.0 - exp(-deg_to_rad(rotation_speed_degrees) * delta)
	var target = direction.angle()
	print_debug("current", rad_to_deg(rotation), "target", rad_to_deg(target))
	global_rotation = lerp_angle(
		global_rotation,
		target,
		t
	)

func _handle_fire(delta: float) -> void:
	if not _is_active:
		return
	
	shoot_counter += delta
	while (shoot_counter > shoot_delay):
		shoot_counter -= shoot_delay
		_handle_shoot()

func _handle_shoot() -> void:
	var spread = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var direction = _shoot_vector().rotated(spread)
	var bullet = $Bullet.duplicate(Node.DUPLICATE_SCRIPTS) as Bullet
	get_tree().root.add_child(bullet)
	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.rotation = direction.angle()
	bullet.direction = direction
	bullet.visible = true
	bullet.global_position = $BarrelEnd.global_position

func _shoot_vector() -> Vector2:
	return ($BarrelEnd.global_position - $BarrelStart.global_position).normalized()
