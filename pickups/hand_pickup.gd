class_name HandPickup
extends Node2D

@export var item_selector: ItemSelector
@export var player: Player

func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D):
	if area.name == "PlayerCollider":
		var name = $Weapon.name
		item_selector.show_choice(
			[name],
			_on_selected,
			_on_cancel
		)

func _on_selected(name: String):
	player.add_weapon($Weapon)
	queue_free()

func _on_cancel():
	queue_free()
