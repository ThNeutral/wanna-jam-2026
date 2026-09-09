class_name Enemy
extends Node2D

@export var speed: float
@export var damage: int
@export var total_health: int
@export var player: Player

var received_damage: int = 0

var _stun_counter: float = 0.0

func current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return current_health() <= 0

func receive_damage(amount: int) -> void:
	received_damage += amount
	if is_dead():
		queue_free()

func is_stunned() -> bool:
	return _stun_counter > 0.0

func apply_stun(duration: float) -> void:
	if duration <= 0.0:
		return
	
	_stun_counter = maxf(_stun_counter, duration)

func set_player(new_player: Player) -> void:
	player = new_player

func _ready() -> void:
	($EnemyCollider as Area2D).area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_stunned():
		return

	var hit_player := Combat.player_of(area)
	if hit_player != null:
		hit_player.receive_damage(damage)

func _process(delta: float) -> void:
	if _stun_counter > 0.0:
		_stun_counter = maxf(_stun_counter - delta, 0.0)
		return
	
	_handle_move_to_player(delta)

func _handle_move_to_player(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	position += global_position.direction_to(player.global_position) * speed * delta
