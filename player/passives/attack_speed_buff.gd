extends BasePassive

@export var attack_speed_multiplier: float = 1.5

func _init() -> void:
	slot = Slot.TOP

func _on_applied() -> void:
	player.attack_speed_multiplier *= attack_speed_multiplier

func _on_removed() -> void:
	if attack_speed_multiplier > 0.0:
		player.attack_speed_multiplier /= attack_speed_multiplier
