class_name PickedWeaponMessage
extends BaseMessage

var names: Array[String]
var on_selected: Callable
var on_cancelled: Callable

func _init(n: Array[String], select: Callable, cancel: Callable) -> void:
	names = n
	on_selected = select
	on_cancelled = cancel
