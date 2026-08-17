class_name DeathUI
extends Control

@export var button: Button
@export var player: Player

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	visible = player.is_dead()
	if player.is_dead():
		Engine.time_scale = 0
