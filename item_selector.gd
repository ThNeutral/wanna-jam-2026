class_name ItemSelector
extends Control

@export var container: VBoxContainer

func show_choice(names: Array[String], callback: Callable) -> void:
	Engine.time_scale = 0
	for i in names.size():
		var button = Button.new()
		button.text = names[i]
		button.pressed.connect(_on_choice_pressed.bind(names[i], callback))
		container.add_child(button)

func _on_choice_pressed(value: String, callback: Callable) -> void:
	clear_choices()
	Engine.time_scale = 1
	callback.call(value)

func clear_choices() -> void:
	for child in container.get_children():
		child.queue_free()
