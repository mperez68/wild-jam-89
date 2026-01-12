class_name PlayerController extends Node

var vehicle: Vehicle

func _ready() -> void:
	if get_parent() is Vehicle and get_parent().is_player:
		vehicle = get_parent()

func _process(_delta: float) -> void:
	if !vehicle or vehicle.dead:
		return
	# Turrets
	var mouse_position: Vector2 = vehicle.get_local_mouse_position()
	if mouse_position != Vector2.ZERO and _is_mouse_in_viewport():
		vehicle.aim_target.position = mouse_position

func _input(event: InputEvent) -> void:	# TODO move to player controller
	if !vehicle or vehicle.dead:
		return
	# Movement
	if event.is_action("accelerate") or event.is_action("reverse") or event.is_action("steer_left") or event.is_action("steer_right"):
		vehicle.move_vector = Input.get_vector("steer_left", "steer_right", "reverse", "accelerate")
	# Guns
	vehicle.fire(event, "fire_01", vehicle.WeaponSlot.PRIMARY)
	vehicle.fire(event, "fire_02", vehicle.WeaponSlot.SECONDARY)
	vehicle.fire(event, "fire_03", vehicle.WeaponSlot.TERTIARY)
	
	if event.is_action("aim_up") or event.is_action("aim_down") or event.is_action("aim_left") or event.is_action("aim_right"):
		vehicle.aim_vector = (Input.get_vector("aim_left", "aim_right", "aim_down", "aim_up") * vehicle.rotate_speed * 2).rotated(vehicle.rotation)

func _is_mouse_in_viewport() -> bool:
	var mouse_pos := get_viewport().get_mouse_position()
	var rect := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	return rect.has_point(mouse_pos)
