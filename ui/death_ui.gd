class_name DeathUI
extends Control

const PAUSE_HOLDER: StringName = &"death"

func _ready() -> void:
	visible = false
	($Button as Button).pressed.connect(_on_button_pressed)
	MessageBus.subscribe(MessageBus.EventType.PLAYER_DIED, _on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"restart"):
		_restart()

func _on_player_died(message: BaseMessage) -> void:
	visible = true
	Pause.hold(PAUSE_HOLDER)

func _on_button_pressed() -> void:
	_restart()

func _restart() -> void:
	Pause.release_all()
	get_tree().reload_current_scene()
