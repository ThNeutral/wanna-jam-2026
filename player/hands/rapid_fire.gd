extends BaseWeapon

@export var bullet_speed: float
@export var shoot_delay: float
var shoot_counter: float

var is_in_super: bool = false

@export var max_charge_scale: float = 3
@export var max_charge_time: float = 1
var charge_time: float

@export var damage: Vector2
func _get_damage() -> float:
	return damage.x if not is_in_super else damage.y

@export var spread_degrees: float

@export var rotation_speed_degrees: float

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	set_is_active(true)

func _process(delta: float) -> void:
	super._process(delta)
	_handle_simple_fire(delta)
	_handle_rotate(delta)
	_handle_charge_super(delta)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var direction = _direction_to_cursor($BarrelEnd.global_position)
	var t = 1.0 - exp(-deg_to_rad(rotation_speed_degrees) * delta)
	var target = direction.angle()
	global_rotation = lerp_angle(
		global_rotation,
		target,
		t
	)

func _handle_simple_fire(delta: float) -> void:
	if not _is_active or is_in_super:
		return
	
	shoot_counter += delta
	while (shoot_counter > shoot_delay):
		shoot_counter -= shoot_delay
		_handle_simple_shoot()

func _handle_simple_shoot() -> void:
	var bullet = $Bullet.duplicate(Node.DUPLICATE_SCRIPTS) as Bullet
	bullet.visible = true
	var spread = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var direction = _shoot_vector().rotated(spread)
	get_tree().root.add_child(bullet)
	_release_bullet(bullet, damage.x, direction, false)

func _handle_charge_super(delta: float) -> void:
	if not _is_active or not is_in_super or super_bullet == null:
		return
	
	charge_time += delta
	var scale = max_charge_scale * charge_time / max_charge_time
	super_bullet.scale = Vector2(scale, scale)
	if charge_time > max_charge_time:
		_handle_release_super()

func _handle_release_super() -> void:
	is_in_super = false
	charge_time = 0
	var direction = _shoot_vector()
	super_bullet.reparent(get_tree().root)
	_release_bullet(super_bullet, damage.y, direction, true)

var super_bullet: Bullet

func _invoke_super() -> void:
	is_in_super = true
	super_bullet = $Bullet.duplicate(Node.DUPLICATE_SCRIPTS) as Bullet
	super_bullet.visible = true
	$BarrelEnd.add_child(super_bullet)

func _release_bullet(bullet: Bullet, damage: int, direction: Vector2, overpenetration: bool) -> void:
	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.rotation = direction.angle()
	bullet.direction = direction
	bullet.global_position = $BarrelEnd.global_position
	bullet.overpenetration = overpenetration

func _shoot_vector() -> Vector2:
	return ($BarrelEnd.global_position - $BarrelStart.global_position).normalized()
