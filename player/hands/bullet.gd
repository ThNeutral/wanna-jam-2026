class_name Bullet
extends Node2D

const CONTAINER_GROUP: StringName = &"projectiles"
const MAXIMUM_TRAVEL_DISTANCE: float = 10000.0

var speed: float
var damage: int
var direction: Vector2
var overpenetration: bool = false

var _travelled: float

func set_armed(value: bool) -> void:
	($BulletCollider as Area2D).monitoring = value

func _ready() -> void:
	($BulletCollider as Area2D).area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var step := direction * speed * delta
	_travelled += step.length()
	position += step
	
	if _travelled > MAXIMUM_TRAVEL_DISTANCE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var enemy := Combat.enemy_of(area)
	if enemy == null:
		return
	
	enemy.receive_damage(damage)
	if not overpenetration:
		queue_free()
