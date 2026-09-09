extends BaseWeapon

@export var bullet_speed: float
@export var shoot_delay: float
@export var damage: Vector2
@export var spread_degrees: float
@export var rotation_speed_degrees: float
@export var max_charge_scale: float = 3.0

var _shoot_counter: float
var _super_bullet: Bullet

func _update(delta: float) -> void:
	_handle_simple_fire(delta)
	_handle_rotate(delta)
	_handle_charge_super()

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	var target := _direction_to_cursor($BarrelEnd.global_position).angle()
	var t := 1.0 - exp(-deg_to_rad(rotation_speed_degrees) * delta)
	global_rotation = lerp_angle(global_rotation, target, t)

func _handle_simple_fire(delta: float) -> void:
	if not _is_active or is_in_super or shoot_delay <= 0.0:
		return
	
	_shoot_counter += delta
	while _shoot_counter > shoot_delay:
		_shoot_counter -= shoot_delay
		_shoot_simple_bullet()

func _shoot_simple_bullet() -> void:
	var bullet := _spawn_bullet()
	_projectile_parent().add_child(bullet)
	
	var spread := deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	_release_bullet(bullet, int(damage.x), _shoot_vector().rotated(spread), false)

func _handle_charge_super() -> void:
	if not _is_active or not is_in_super or not is_instance_valid(_super_bullet):
		return
	
	var charge_scale := max_charge_scale * super_progress()
	_super_bullet.scale = Vector2(charge_scale, charge_scale)

func _on_super_started() -> void:
	_super_bullet = _spawn_bullet()
	$BarrelEnd.add_child(_super_bullet)

func _on_super_ended() -> void:
	if not is_instance_valid(_super_bullet):
		_super_bullet = null
		return
	
	var bullet := _super_bullet
	_super_bullet = null
	bullet.reparent(_projectile_parent())
	_release_bullet(bullet, int(damage.y), _shoot_vector(), true)

func _projectile_parent() -> Node:
	var container := get_tree().get_first_node_in_group(Bullet.CONTAINER_GROUP)
	return container if container != null else get_tree().root

func _spawn_bullet() -> Bullet:
	var bullet := $Bullet.duplicate(Node.DUPLICATE_SCRIPTS) as Bullet
	bullet.visible = true
	bullet.set_armed(false)
	return bullet

func _release_bullet(
	bullet: Bullet,
	bullet_damage: int,
	direction: Vector2,
	overpenetration: bool
) -> void:
	bullet.damage = bullet_damage
	bullet.speed = bullet_speed
	bullet.direction = direction
	bullet.rotation = direction.angle()
	bullet.global_position = $BarrelEnd.global_position
	bullet.overpenetration = overpenetration
	bullet.set_armed(true)

func _shoot_vector() -> Vector2:
	return ($BarrelStart.global_position).direction_to($BarrelEnd.global_position)
