extends BaseWeapon

@export var rotation_speed_degrees: float
@export var damage: int
@export var shield_size: int

func set_is_active(new_value: bool) -> void:
	_is_active = new_value
	$Drones.visible = new_value

func _ready() -> void:
	($Drones/Drone1/DroneCollider as Area2D).area_entered.connect(_on_area_entered)
	($Drones/Drone2/DroneCollider as Area2D).area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	_handle_rotate(delta)

func _handle_rotate(delta: float) -> void:
	if not _is_active:
		return
	
	$Drones.rotation += delta * deg_to_rad(rotation_speed_degrees)

func _on_area_entered(area: Area2D) -> void:
	var enemy := Combat.enemy_of(area)
	if enemy != null:
		enemy.receive_damage(damage)

func _on_super_started() -> void:
	if is_instance_valid(player):
		player.shield = shield_size

func _on_super_ended() -> void:
	if is_instance_valid(player):
		player.shield = 0
