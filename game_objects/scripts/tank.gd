class_name Tank extends CharacterBody2D

enum WeaponSlot{ PRIMARY, SECONDARY, TERTIARY }

@onready var turret: Node2D = %Turret
@onready var camera: Camera2D = %Camera
@onready var rotation_nodes: Array[Node] = [ %Sprite2D, %CollisionPolygon2D, %CameraHolder, %Reticle, %Line, %Line2, %Line3 ]
@onready var reticle: Control = %Reticle
@onready var line: Array[Control] = [ %Reticle, %Line, %Line2, %Line3 ]
@onready var aim_target: Reticle = %AimTarget
#@onready var reticle_container: Control = %ReticleContainer

@export var speed: float = 500.0
@export_range(0, 90, 0.1, "or_greater") var rotate_speed: float = 1.4
@export_range(0, 90, 0.1, "or_greater") var turret_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var friction: float = 0.95
@export_range(0.0, 1.0, 0.01) var reverse_multiplier: float = 0.5
@export var camera_enabled: bool = false:
	set(value):
		camera_enabled = value
		if camera:
			camera.enabled = camera_enabled

var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.ZERO
var steer_rotation: float = 0:
	set(value):
		turret.rotate(value - steer_rotation)
		steer_rotation = value
		if !rotation_nodes.is_empty() and rotation_nodes.front():
			for node in rotation_nodes:
				node.rotation = steer_rotation

# ENGINE
func _ready() -> void:
	camera_enabled = camera_enabled
	steer_rotation = steer_rotation

func _physics_process(delta: float) -> void:
	var new_rotation: float = move_vector.x * rotate_speed * delta * (-1.0 if move_vector.y < 0.0 else 1.0)
	
	# Turret
	var reticle_angle: float = reticle.position.angle()
	var cursor_angle: float = aim_target.position.angle()
	var total_speed: float = turret_speed
	var new_angle: float = lerp_angle(reticle_angle, cursor_angle, min(1.0, ((total_speed) * delta) / abs(angle_difference(reticle_angle, cursor_angle))))
	new_angle += new_rotation
	
	var radius: float = reticle.position.length()
	reticle.position = Vector2.from_angle(new_angle) * radius
	
	turret.rotation = reticle.position.angle()
	_draw_reticle()
	
	# Movement
	steer_rotation += new_rotation
	var lateral_acceleration: float = move_vector.y * speed * delta
	velocity += (Vector2(lateral_acceleration, 0) * (1.0 if lateral_acceleration > 0 else reverse_multiplier)).rotated(steer_rotation)
	velocity *= friction
	var collide := move_and_collide(velocity, true)
	if collide:
		print(collide)
	move_and_slide()

func _process(_delta: float) -> void:
	# Turrets
	var mouse_position: Vector2 = get_local_mouse_position()
	if mouse_position != Vector2.ZERO and _is_mouse_in_viewport():
		aim_target.position = mouse_position

func _input(event: InputEvent) -> void:	# TODO move to player controller
	# Movement
	if event.is_action("accelerate") or event.is_action("reverse") or event.is_action("steer_left") or event.is_action("steer_right"):
		move_vector = Input.get_vector("steer_left", "steer_right", "reverse", "accelerate")
	# Guns
	if event.is_action_pressed("fire_01"):
		fire(WeaponSlot.PRIMARY)
	elif event.is_action_pressed("fire_02"):
		fire(WeaponSlot.SECONDARY)
	elif event.is_action_pressed("fire_03"):
		fire(WeaponSlot.TERTIARY)
	
	if event.is_action("aim_up") or event.is_action("aim_down") or event.is_action("aim_left") or event.is_action("aim_right"):
		aim_vector = (Input.get_vector("aim_left", "aim_right", "aim_down", "aim_up") * rotate_speed * 2).rotated(rotation)


# PUBLIC
func fire(slot: WeaponSlot):
	print(slot)


# PRIVATE
func _draw_reticle():
	for i in line.size():
		line[i].position = lerp(reticle.position, Vector2.ZERO, float(i) / float(line.size()))

func _is_mouse_in_viewport() -> bool:
	var mouse_pos := get_viewport().get_mouse_position()
	var rect := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	return rect.has_point(mouse_pos)


# SIGNALS
