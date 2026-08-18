class_name Enemy
extends Node2D

@export var speed: float
@export var player: Player

@export var damage: int
@export var total_health: int
var received_damage: int = 0
func current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return current_health() <= 0

func receive_damage(damage: int):
	received_damage += damage
	if is_dead():
		queue_free()

func _ready() -> void:
	$EnemyCollider.area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area.name == "PlayerCollider":
		var player = area.get_parent() as Player
		player.receive_damage(damage)

func set_player(new_player: Player) -> void:
	player = new_player 

func set_speed(new_speed: float) -> void:
	speed = new_speed 

func _process(delta: float) -> void:
	_handle_move_to_player(delta)

func _handle_move_to_player(delta: float) -> void:
	var direction_to_player = (player.global_position - global_position).normalized()
	position += direction_to_player * speed * delta;
