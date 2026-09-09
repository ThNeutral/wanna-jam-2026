extends Node

const PAUSE_HOLDER: StringName = &"passive_selection"

@onready var container: VBoxContainer = $VBoxContainer

@export var player: Player

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func show_choice(callback: Callable) -> void:
	var empty_slots = player.get_empty_passive_slots()
	var all_slots = player.get_all_passive_slots()

	for slot in all_slots:
		var is_empty = empty_slots.has(slot)


func _add_button(text: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	container.add_child(button)