class_name PassiveSelection
extends Control

const PAUSE_HOLDER: StringName = &"passive_selection"
const TAKEN_SLOT_FONT_COLOR: Color = Color("333333")

@export var player: Player

@onready var container: VBoxContainer = $VBoxContainer

var _is_showing: bool = false
var _on_cancel: Callable

func _ready() -> void:
	MessageBus.subscribe(MessageBus.EventType.PICKED_PASSIVE, _show_choice)

func _show_choice(message: BaseMessage) -> void:	
	if _is_showing:
		return
	
	if player == null:
		push_warning("Player is not set")
		return
	
	var picked_passive_message = message as PickedPassiveMessage
	
	_is_showing = true
	_on_cancel = picked_passive_message.on_cancelled
	visible = true
	Pause.hold(PAUSE_HOLDER)
	
	var empty_slots := player.get_empty_passive_slots()
	for slot in player.get_all_passive_slots():
		var on_success = picked_passive_message.on_selected
		var on_pressed := _on_slot_pressed.bind(slot, on_success) if empty_slots.has(slot) else Callable()
		_add_button(_slot_name(slot), on_pressed)
	
	_add_button("Cancel", _on_cancelled.bind(_on_cancel))
	return

func clear_choices() -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if _is_showing and event.is_action_pressed(&"cancel"):
		_on_cancelled(_on_cancel)

func _slot_name(slot: BasePassive.Slot) -> String:
	return (BasePassive.Slot.keys()[slot] as String).capitalize()

func _add_button(text: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = text
	
	if on_pressed.is_valid():
		button.pressed.connect(on_pressed)
	else:
		button.disabled = true
		button.add_theme_color_override(&"font_disabled_color", TAKEN_SLOT_FONT_COLOR)
	
	container.add_child(button)

func _on_slot_pressed(slot: BasePassive.Slot, callback: Callable) -> void:
	_close()
	if callback.is_valid():
		callback.call(slot)

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
