extends BasePassive

@export var speed_multiplier: float = 1.5

func _init() -> void:
	slot = Slot.BOTTOM

func _on_applied() -> void:
	player.speed_multiplier *= speed_multiplier

func _on_removed() -> void:
	if speed_multiplier > 0.0:
		player.speed_multiplier /= speed_multiplier
