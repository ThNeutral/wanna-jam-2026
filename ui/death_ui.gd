class_name DeathUI
extends Control

@export var player: Player

func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	print_debug("test")
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	visible = player.is_dead()
	if player.is_dead():
		Engine.time_scale = 0
