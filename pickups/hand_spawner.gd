extends Node2D

@export var prefab: PackedScene
@export var number_of_hands: int
@export var minimal_distance: float
@export var spawn_area: Rect2

@export var item_selector: ItemSelector

const NUMBER_OF_ATTEMPTS = 1000

func _ready() -> void:
	_handle_spawn()

func _handle_spawn() -> void:
	var spawned: Array[Vector2] = []
	for i in number_of_hands:
		var hand_pickup = prefab.instantiate() as HandPickup
		for attempt in NUMBER_OF_ATTEMPTS:
			var spawn_point_candidate = _sample_random_point_in_spawn_area()
			if (!_is_point_allowed(spawn_point_candidate, spawned)):
				assert(attempt != NUMBER_OF_ATTEMPTS - 1, "Failed to generate point.")
				continue
			
			spawned.append(spawn_point_candidate)
			hand_pickup.global_position = spawn_point_candidate
			hand_pickup.item_selector = item_selector
			add_child(hand_pickup)
			break

func _sample_random_point_in_spawn_area() -> Vector2:
	return Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	) 

func _is_point_allowed(candidate: Vector2, existing: Array[Vector2]) -> bool:
	for e in existing:
		if candidate.distance_to(e) <= minimal_distance:
			return false
	return true
