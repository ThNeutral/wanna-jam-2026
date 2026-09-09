class_name BasePassive
extends Node2D

enum Slot {TOP, MIDDLE, BOTTOM}

@export var slot: Slot = Slot.TOP

var player: Player

var _is_active: bool = false

func set_is_active(new_value: bool) -> void:
	_is_active = new_value

func on_added(new_player: Player) -> void:
	player = new_player
	set_is_active(true)
	_on_applied()

func on_removed() -> void:
	_on_removed()
	set_is_active(false)
	player = null

func _process(delta: float) -> void:
	_update(delta)

func _update(_delta: float) -> void:
	pass

func _attack_delta(delta: float) -> float:
	return player.attack_delta(delta) if player != null else delta

func _on_applied() -> void:
	pass

func _on_removed() -> void:
	pass
