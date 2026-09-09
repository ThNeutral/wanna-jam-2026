class_name HandPickup
extends Node2D

@export var item_selector: ItemSelector
@export var player: Player
@export var weapon: BaseWeapon

func add_weapon(new_weapon: BaseWeapon) -> void:
	weapon = new_weapon
	weapon.position = Vector2.ZERO
	add_child(weapon)

func _ready() -> void:
	($Area2D as Area2D).area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if Combat.player_of(area) == null or weapon == null:
		return
	
	if item_selector == null or player == null:
		push_warning("HandPickup at %s is not wired to a player or item selector" % global_position)
		return
	
	item_selector.show_choice([weapon.name], _on_selected, _on_cancel)

func _on_selected(_choice: String) -> void:
	if player.add_weapon(weapon):
		queue_free()

func _on_cancel() -> void:
	queue_free()
