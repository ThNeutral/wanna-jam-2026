extends BaseWeapon

@export var player: Player

@export var rotation_speed_degrees: float
@export var damage: int

@export var super_length: float
var super_length_counter: float

@export var shield_size: float
var current_shield_size: float

var is_in_super: bool = false

func set_is_active(new_value: bool) -> void:
	_is_active = new_value
	$Drones.visible = new_value

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

func _process(delta: float) -> void:
	super._process(delta)
	_handle_shield(delta)

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

func _handle_shield(delta: float) -> void:
	if not _is_active or not is_in_super:
		return
	
	super_length_counter += delta
	if super_length_counter > super_length:
		_end_shield()

func _invoke_super() -> void:
	is_in_super = true
	player.shield = shield_size

func _end_shield() -> void:
	super_length_counter = 0
	is_in_super = false
	player.shield = 0
