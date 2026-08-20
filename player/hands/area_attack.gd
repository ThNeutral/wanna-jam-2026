extends BaseWeapon

@export var radius: float
@export var attack_interval: float
@export var damage: int
var attack_counter: float = 0

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	set_is_active(true)

func set_is_active(new_value: bool) -> void:
	_is_active = new_value
	queue_redraw()

func _draw() -> void:
	draw_circle(
		position,
		radius,
		Color.BLACK if _is_active else Color.TRANSPARENT, 
		false, 
		5
	)
	var shape = $AreaAttackCollider/CollisionShape2D.shape as CircleShape2D
	shape.radius = radius

func _process(delta: float) -> void:
	_handle_attack(delta)

func _handle_attack(delta: float) -> void:
	if not _is_active:
		return
	
	attack_counter += delta
	
	while attack_counter > attack_interval:
		attack_counter = max(0, attack_counter - attack_interval)
		var area = $AreaAttackCollider as Area2D
		var overlapping_areas = area.get_overlapping_areas()
		for overlapping_area in overlapping_areas:
			if overlapping_area.name == "EnemyCollider":
				var enemy = overlapping_area.get_parent() as Enemy
				enemy.receive_damage(damage)
	
