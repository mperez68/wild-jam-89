class_name Missile extends RigidBody2D

@export var speed: float = 1000.0
@export var speed_tolerance: float = 50.0
@export var acceleration: float = 0.0
@export var acceleration_tolerance: float = 0.0
@export var scatter: float = 15.0
@export var damage: int = 1
@export var piercing: int = 0

# ENGINE
func _ready():
	linear_velocity = Vector2(speed + (randf_range(-speed_tolerance, speed_tolerance)), 0).rotated(rotation + deg_to_rad(randf_range(-scatter, scatter)))
	constant_force = Vector2(acceleration + (randf_range(-acceleration_tolerance, acceleration_tolerance)), 0).rotated(rotation)



# PUBLIC


# PRIVATE


# SIGNALS
func _on_body_entered(body: Node) -> void:
	if body is Vehicle:
		body.damage(damage, piercing)
	queue_free()
