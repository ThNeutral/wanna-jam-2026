class_name PickedPassiveMessage
extends BaseMessage

var on_selected: Callable
var on_cancelled: Callable

func _init(select: Callable, cancel: Callable) -> void:
	on_selected = select
	on_cancelled = cancel
