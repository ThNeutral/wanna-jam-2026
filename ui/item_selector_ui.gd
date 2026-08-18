class_name ItemSelector
extends Control

func show_choice(
	names: Array[String], 
	on_success: Callable, 
	on_cancel: Callable
) -> void:
	visible = true
	
	Engine.time_scale = 0
	for i in names.size():
		var button = Button.new()
		button.text = names[i]
		button.pressed.connect(_on_choice_pressed.bind(names[i], on_success))
		$VBoxContainer.add_child(button)
		
	var button = Button.new()
	button.text = "Cancel"
	button.pressed.connect(_on_cancelled.bind(on_cancel))
	$VBoxContainer.add_child(button)

func _on_choice_pressed(value: String, callback: Callable) -> void:
	_on_choice()
	callback.call(value)

func _on_cancelled(callback: Callable) -> void:
	_on_choice()
	callback.call()

func _on_choice() -> void:
	clear_choices()
	Engine.time_scale = 1
	visible = false

func clear_choices() -> void:
	for child in $VBoxContainer.get_children():
		child.queue_free()
