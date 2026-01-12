class_name PlayerController extends Node

var tank: Tank

func _ready() -> void:
	if get_parent() is Tank and get_parent().is_player:
		tank = get_parent()

func _process(_delta: float) -> void:
	if !tank or tank.dead:
		return
	# Turrets
	var mouse_position: Vector2 = tank.get_local_mouse_position()
	if mouse_position != Vector2.ZERO and _is_mouse_in_viewport():
		tank.aim_target.position = mouse_position

func _input(event: InputEvent) -> void:	# TODO move to player controller
	if !tank or tank.dead:
		return
	# Movement
	if event.is_action("accelerate") or event.is_action("reverse") or event.is_action("steer_left") or event.is_action("steer_right"):
		tank.move_vector = Input.get_vector("steer_left", "steer_right", "reverse", "accelerate")
	# Guns
	tank.fire(event, "fire_01", tank.WeaponSlot.PRIMARY)
	tank.fire(event, "fire_02", tank.WeaponSlot.SECONDARY)
	tank.fire(event, "fire_03", tank.WeaponSlot.TERTIARY)
	
	if event.is_action("aim_up") or event.is_action("aim_down") or event.is_action("aim_left") or event.is_action("aim_right"):
		tank.aim_vector = (Input.get_vector("aim_left", "aim_right", "aim_down", "aim_up") * tank.rotate_speed * 2).rotated(tank.rotation)

func _is_mouse_in_viewport() -> bool:
	var mouse_pos := get_viewport().get_mouse_position()
	var rect := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	return rect.has_point(mouse_pos)
