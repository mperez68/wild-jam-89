class_name Missile extends RigidBody2D

@export var speed: float = 1000.0
@export var damage: int = 1

# ENGINE
func _ready():
	linear_velocity = Vector2(speed, 0).rotated(rotation)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_body_entered(body: Node) -> void:
	if body is Tank:
		body.health -= damage
	queue_free()
