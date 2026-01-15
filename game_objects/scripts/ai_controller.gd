class_name AiController extends Node

const SHOOT_RADIUS: float = 300.0

var vehicle: Vehicle
var nav: NavigationAgent2D


func _ready() -> void:
	if get_parent() is Vehicle and !get_parent().is_player:
		vehicle = get_parent()

func nav_ready() -> void:
	nav.velocity_computed.connect(_on_velocity_computed)

func _physics_process(_delta: float) -> void:
	if !vehicle or vehicle.dead:
		if vehicle:
			vehicle.fire_all(false)
		return
	if !nav:
		nav = vehicle.nav
		nav.velocity_computed.connect(_on_velocity_computed)
	
	# Pursure target if it's in range
	if !vehicle.targets.is_empty():
		var target: Vehicle
		for tgt: Vehicle in vehicle.targets:
			if tgt.is_player:
				target = tgt
				break
		if !target:
			return
		vehicle.aim_target.global_position = target.global_position
		# Shoot in range
		if vehicle.global_position.distance_to(target.global_position) < SHOOT_RADIUS:
			vehicle.fire_all(true)
		else:
			nav_to(vehicle.global_position)
			vehicle.fire_all(false)
	# Else, hit rally points.
	elif nav.is_target_reached() or nav.target_position == Vector2.ZERO:
		nav.target_position = vehicle.rally_points.pick_random()

func nav_to(target: Vector2):
	nav.target_position = target

func _on_velocity_computed(safe_velocity: Vector2):
	if vehicle and !vehicle.dead:
		vehicle.move_vector = safe_velocity.normalized()
