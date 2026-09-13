class_name PassivePickup
extends Node2D

@export var player: Player
var _passives: Array[BasePassive] = []

func _ready() -> void:
	($Area2D as Area2D).area_entered.connect(_on_area_entered)

	_passives.append($Passives/AttackSpeedBuff as BasePassive)
	_passives.append($Passives/AreaAttack as BasePassive)
	_passives.append($Passives/MoveSpeedBuff as BasePassive)

func _on_area_entered(area: Area2D) -> void:
	if Combat.player_of(area) == null:
		return
	
	var message = PickedPassiveMessage.new(_on_selected, _on_cancelled)
	MessageBus.publish(MessageBus.EventType.PICKED_PASSIVE, message)

func _on_selected(slot: BasePassive.Slot) -> void:
	var passive_index = _passives.find_custom(
		func(p: BasePassive): return p.slot == slot
	)
	
	if passive_index == -1:
		push_warning("Did not find passive for slot")
		return
	
	var passive = _passives[passive_index]
	if player.add_passive(passive):
		queue_free()

func _on_cancelled() -> void:
	queue_free()
