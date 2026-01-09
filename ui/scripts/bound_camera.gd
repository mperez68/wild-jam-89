class_name BoundCamera extends Camera2D

@export var locked: bool = true
@export var focus_target: Node2D
@export var scroll_speed: float = 400.0

var move_vector: Vector2 = Vector2.ZERO


# ENGINE
func _physics_process(delta: float) -> void:
	move_vector = Vector2.ZERO if locked else Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += move_vector * scroll_speed * delta
	var view_size := get_viewport_rect().size
	position.x = clamp(position.x, limit_left + view_size.x / 2, limit_right - view_size.x / 2)
	position.y = clamp(position.y, limit_top + view_size.y / 2, limit_bottom - view_size.y / 2)


# PUBLIC
func set_limits(boundaries: Rect2):
	var view_size := get_viewport_rect().size
	limit_left = int(boundaries.position.x - (view_size.x / 2))
	limit_top = int(boundaries.position.y - (view_size.y / 2))
	limit_right = int(boundaries.size.x + (view_size.x / 2))
	limit_bottom = int(boundaries.size.y + (view_size.y / 2))


# PRIVATE


# SIGNALS


func _on_start_timer_timeout() -> void:
	locked = focus_target != null
