extends Node2D

@export var area: Area2D
@export var item_selector: ItemSelector

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D):
	print_debug(area.name)
	if area.name == "PlayerCollider":
		item_selector.show_choice(
			["One", "Two", "Three"],
			_on_selected,
			_on_cancel
		)

func _on_selected(name: String):
	print_debug("Selected", name)
	queue_free()

func _on_cancel():
	queue_free()
