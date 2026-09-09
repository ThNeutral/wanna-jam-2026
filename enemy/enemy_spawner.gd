extends Node2D

@export var prefab: PackedScene
@export var spawn_interval: float
@export var spawn_radius: float = 0.0
@export var player: Player

var _counter: float

func _process(delta: float) -> void:
	_handle_spawn(delta)

func _handle_spawn(delta: float) -> void:
	if prefab == null or spawn_interval <= 0.0:
		return
	
	_counter += delta
	while _counter > spawn_interval:
		_counter -= spawn_interval
		var enemy := prefab.instantiate() as Enemy
		enemy.set_player(player)
		add_child(enemy)
		enemy.position = _sample_spawn_offset()

func _sample_spawn_offset() -> Vector2:
	if spawn_radius <= 0.0:
		return Vector2.ZERO
	
	return Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(0.0, spawn_radius)
