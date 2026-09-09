class_name Enemy
extends Node2D

@export var speed: float
@export var damage: int
@export var total_health: int
@export var player: Player

var received_damage: int = 0

func current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return current_health() <= 0

func receive_damage(amount: int) -> void:
	received_damage += amount
	if is_dead():
		queue_free()

func set_player(new_player: Player) -> void:
	player = new_player

func _ready() -> void:
	($EnemyCollider as Area2D).area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hit_player := Combat.player_of(area)
	if hit_player != null:
		hit_player.receive_damage(damage)

func _process(delta: float) -> void:
	_handle_move_to_player(delta)

func _handle_move_to_player(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	position += global_position.direction_to(player.global_position) * speed * delta
