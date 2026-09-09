extends BaseWeapon

@export var radius: float
@export var attack_interval: float
@export var damage: int

var _attack_counter: float

func set_is_active(new_value: bool) -> void:
	_is_active = new_value
	queue_redraw()

func _ready() -> void:
	var collider := $AreaAttackCollider/CollisionShape2D as CollisionShape2D
	var shape := (collider.shape as CircleShape2D).duplicate() as CircleShape2D
	shape.radius = radius
	collider.shape = shape

func _draw() -> void:
	if not _is_active:
		return
	
	draw_circle(Vector2.ZERO, radius, Color.BLACK, false, 5)

func _update(delta: float) -> void:
	_handle_attack(delta)

func _handle_attack(delta: float) -> void:
	if not _is_active or attack_interval <= 0.0:
		return
	
	_attack_counter += delta
	while _attack_counter > attack_interval:
		_attack_counter -= attack_interval
		_damage_overlapping_enemies()

func _damage_overlapping_enemies() -> void:
	for area in ($AreaAttackCollider as Area2D).get_overlapping_areas():
		var enemy := Combat.enemy_of(area)
		if enemy != null:
			enemy.receive_damage(damage)
