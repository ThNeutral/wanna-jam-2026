class_name Player
extends Node2D

signal died

@export var speed: float

@export var zoom_limits: Vector2 = Vector2(0.1, 5.0)
@export var initial_zoom: float = 1.0
@export var zoom_step: float

@export var total_health: int

var shield: int
var received_damage: int = 0
var attack_speed_multiplier: float = 1.0
var speed_multiplier: float = 1.0

var _handles: Array[Node2D] = []
var _passives: Dictionary[BasePassive.Slot, Node2D] = {}
var _camera: Camera2D

func _ready() -> void:
	_camera = $Camera as Camera2D
	
	_handles.append($Mounts/MountRT)
	_handles.append($Mounts/MountLT)
	_handles.append($Mounts/MountRB)
	_handles.append($Mounts/MountLB)

	_passives[BasePassive.Slot.TOP] = $Passives/PassiveTop
	_passives[BasePassive.Slot.MIDDLE] = $Passives/PassiveMiddle
	_passives[BasePassive.Slot.BOTTOM] = $Passives/PassiveBottom

	_set_zoom(initial_zoom)

func attack_delta(delta: float) -> float:
	return delta * attack_speed_multiplier

func current_health() -> int:
	return total_health - received_damage

func is_dead() -> bool:
	return current_health() <= 0

func receive_damage(amount: int) -> void:
	if is_dead():
		return
	
	if shield > 0:
		shield = max(0, shield - amount)
		return
	
	received_damage += amount
	if is_dead():
		died.emit()

func add_weapon(weapon: BaseWeapon) -> bool:
	var index := _get_empty_handle_index()
	if index == -1:
		return false
	
	weapon.reparent(_handles[index])
	weapon.position = Vector2.ZERO
	weapon.rotation = 0.0
	weapon.player = self
	weapon.set_index(index)
	weapon.on_added()
	return true

func add_passive(passive: BasePassive) -> bool:
	if not _is_passive_slot_available(passive.slot):
		push_warning("Tried to add passive to taken slot %s" % passive.slot)
		return false
	
	passive.reparent(_passives[passive.slot])
	passive.position = Vector2.ZERO
	passive.rotation = 0.0
	passive.on_added(self)
	return true

func _process(delta: float) -> void:
	_handle_pan_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_zoom_in"):
		_set_zoom(_camera.zoom.x + zoom_step)
	elif event.is_action_pressed(&"camera_zoom_out"):
		_set_zoom(_camera.zoom.x - zoom_step)

func _set_zoom(value: float) -> void:
	var clamped := clampf(value, zoom_limits.x, zoom_limits.y)
	_camera.zoom = Vector2(clamped, clamped)

func _handle_pan_camera(delta: float) -> void:
	var direction := Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down"
	)
	position += direction * speed * speed_multiplier * delta

func get_empty_passive_slots() -> Array[BasePassive.Slot]:
	var empty_slots: Array[BasePassive.Slot] = []
	for slot in get_all_passive_slots():
		if _is_passive_slot_available(slot):
			empty_slots.append(slot)
	
	return empty_slots

func get_all_passive_slots() -> Array[BasePassive.Slot]:
	var slots: Array[BasePassive.Slot] = []
	slots.assign(BasePassive.Slot.values())
	return slots

func _get_empty_handle_index() -> int:
	return _find_node_with_no_child(_handles)

func _is_passive_slot_available(slot: BasePassive.Slot) -> bool:
	return _has_no_children(_passives[slot])

func _find_node_with_no_child(arr: Array[Node2D]) -> int:
	for index in arr.size():
		if _has_no_children(arr[index]):
			return index
	
	return -1

func _has_no_children(node: Node2D) -> bool:
	return node.get_child_count() == 0
