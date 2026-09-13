class_name PassivePickup
extends Node2D

@export var passive_selector: PassiveSelector
@export var player: Player
@export var passive: BasePassive

func add_passive(new_passive: BasePassive) -> void:
	passive = new_passive
	passive.position = Vector2.ZERO
	add_child(passive)

func _ready() -> void:
	($Area2D as Area2D).area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if Combat.player_of(area) == null or passive == null:
		return
	
	if passive_selector == null or player == null:
		push_warning("PassivePickup at %s is not wired to a player or passive selector" % global_position)
		return
	
	passive_selector.show_choice(_on_selected, _on_cancel)

func _on_selected(slot: BasePassive.Slot) -> void:
	passive.slot = slot
	if player.add_passive(passive):
		queue_free()

func _on_cancel() -> void:
	queue_free()
