class_name Missile extends RigidBody2D

@export var speed: float = 1000.0
@export var scatter: float = 30.0
@export var damage: int = 1
@export var piercing: int = 0

# ENGINE
func _ready():
	linear_velocity = Vector2(speed, 0).rotated(rotation + deg_to_rad(randf_range(-scatter, scatter)))


# PUBLIC


# PRIVATE


# SIGNALS
func _on_body_entered(body: Node) -> void:
	if body is Vehicle:
		body.damage(damage, piercing)
	queue_free()
