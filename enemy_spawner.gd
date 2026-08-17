extends Node2D

@export var prefab: PackedScene
@export var spawn_interval: float

@export var player: Player

var _counter: float = 0

func _process(delta: float) -> void:
	_handle_spawn(delta)

func _handle_spawn(delta: float) -> void:
	_counter += delta
	while (_counter > spawn_interval):
		_counter = max(0, _counter - spawn_interval)
		var enemy: Enemy = prefab.instantiate()
		enemy.position = Vector2.ZERO
		enemy.set_player(player)
		add_child(enemy)
