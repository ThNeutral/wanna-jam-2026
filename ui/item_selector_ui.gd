class_name ItemSelector
extends Control

const PAUSE_HOLDER: StringName = &"item_selector"

@onready var container: VBoxContainer = $VBoxContainer

var _is_showing: bool = false
var _on_cancel: Callable

func _ready() -> void:
	visible = false
	
	MessageBus.subscribe(
		MessageBus.EventType.PICKED_WEAPON,
		_show_choice
	)

func _show_choice(message: BaseMessage) -> bool:
	if _is_showing:
		return false
	
	var picked_weapon_message = message as PickedWeaponMessage
	
	_is_showing = true
	_on_cancel = picked_weapon_message.on_cancelled
	visible = true
	Pause.hold(PAUSE_HOLDER)
	
	for choice in picked_weapon_message.names:
		_add_button(choice, _on_choice_pressed.bind(choice, picked_weapon_message.on_selected))
	
	_add_button("Cancel", _on_cancelled.bind(picked_weapon_message.on_cancelled))
	return true

func clear_choices() -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if _is_showing and event.is_action_pressed(&"cancel"):
		_on_cancelled(_on_cancel)

func _add_button(text: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	container.add_child(button)

func _on_choice_pressed(choice: String, callback: Callable) -> void:
	_close()
	if callback.is_valid():
		callback.call(choice)

func _on_cancelled(callback: Callable) -> void:
	_close()
	if callback.is_valid():
		callback.call()

func _close() -> void:
	clear_choices()
	_is_showing = false
	_on_cancel = Callable()
	Pause.release(PAUSE_HOLDER)
	visible = false
