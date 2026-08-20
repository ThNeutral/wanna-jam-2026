extends Node2D
class_name Bullet

var speed: float
var damage: int
var direction: Vector2

const MAXIMUM_TRAVEL_DISTANCE: float = 10000
var travelled: float

func _ready() -> void:
	$BulletCollider.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if travelled > MAXIMUM_TRAVEL_DISTANCE:
		queue_free()

func _physics_process(delta: float) -> void:
	var diff = direction * delta * speed
	travelled += diff.length()
	position += diff

func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyCollider":
		var enemy = area.get_parent() as Enemy
		enemy.receive_damage(damage)
		queue_free()
