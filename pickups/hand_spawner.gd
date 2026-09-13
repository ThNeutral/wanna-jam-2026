extends Node2D

const NUMBER_OF_ATTEMPTS: int = 1000

@export var hand_pickup_prefab: PackedScene
@export var weapons: Array[PackedScene]
@export var number_of_hands: int
@export var minimal_distance: float
@export var spawn_area: Rect2

@export var player: Player

func _ready() -> void:
	_handle_spawn()

func _handle_spawn() -> void:
	if hand_pickup_prefab == null or weapons.is_empty():
		push_warning("HandSpawner: nothing to spawn, prefab or weapon list is empty")
		return
	
	var spawned: Array[Vector2] = []
	for i in number_of_hands:
		var spawn_point := _find_free_spawn_point(spawned)
		if spawn_point == Vector2.INF:
			push_warning("HandSpawner: placed %d/%d hands, no free spot after %d attempts" % [
				i, number_of_hands, NUMBER_OF_ATTEMPTS
			])
			return
		
		spawned.append(spawn_point)
		_spawn_hand_pickup(spawn_point)

func _find_free_spawn_point(existing: Array[Vector2]) -> Vector2:
	for attempt in NUMBER_OF_ATTEMPTS:
		var candidate := _sample_random_point_in_spawn_area()
		if _is_point_allowed(candidate, existing):
			return candidate
	
	return Vector2.INF

func _spawn_hand_pickup(spawn_point: Vector2) -> void:
	var hand_pickup := hand_pickup_prefab.instantiate() as HandPickup
	hand_pickup.player = player
	add_child(hand_pickup)
	hand_pickup.global_position = spawn_point
	hand_pickup.add_weapon(weapons.pick_random().instantiate() as BaseWeapon)

func _sample_random_point_in_spawn_area() -> Vector2:
	return Vector2(
		randf_range(spawn_area.position.x, spawn_area.end.x),
		randf_range(spawn_area.position.y, spawn_area.end.y)
	)

func _is_point_allowed(candidate: Vector2, existing: Array[Vector2]) -> bool:
	for point in existing:
		if candidate.distance_to(point) <= minimal_distance:
			return false
	
	return true
