extends BaseWeapon

@export var rotation_speed_degrees: float
@export var damage: int

func on_added(
	initial_position: Vector2,
	initial_rotation: float
) -> void:
	position = initial_position
	rotation = initial_rotation
	set_is_active(true)

func _ready() -> void:
	$Drones/Drone1/DroneCollider.area_entered.connect(_on_area_entered)
	$Drones/Drone2/DroneCollider.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	_handle_rotate(delta)

func _handle_rotate(delta: float) -> void:
	if !_is_active:
		return
	
	$Drones.rotation += delta * deg_to_rad(rotation_speed_degrees)

func _on_area_entered(area: Area2D):
	if area.name == "EnemyCollider":
		var enemy = area.get_parent() as Enemy
		enemy.receive_damage(damage)
