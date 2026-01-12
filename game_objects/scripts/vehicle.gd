class_name Vehicle extends CharacterBody2D

signal died

enum WeaponSlot{ PRIMARY, SECONDARY, TERTIARY }

const COLLISION_DAMAGE: int = 10
const COLLISION_SPEED: float = 250.0
const MINIMUM_DAMAGE: int = 1

@onready var turret: Node2D = %Turret
@onready var camera: Camera2D = %Camera
@onready var reticle: Control = %Reticle
@onready var aim_target: Reticle = %AimTarget
@onready var cannon_end: Node2D = %CannonEnd
@onready var reticle_container: Control = %ReticleContainer
@onready var line: Array[Control] = [ %Reticle, %Line, %Line2, %Line3 ]
@onready var rotation_nodes: Array[Node] = [ %Sprite2D, %CollisionPolygon2D, %CameraHolder,
											%Reticle, %Line, %Line2, %Line3 ]
@onready var weapon_timers: Dictionary[WeaponSlot, Timer] = {
	WeaponSlot.PRIMARY: %PrimaryWeaponTimer,
	WeaponSlot.SECONDARY: %SecondaryWeaponTimer,
	WeaponSlot.TERTIARY: %TertiaryWeaponTimer
}

@export_range(1, 150, 1.0, "or_greater") var max_health: int = 100
@export var speed: float = 500.0
@export_range(0, 90, 0.1, "or_greater") var rotate_speed: float = 1.4
@export_range(0, 90, 0.1, "or_greater") var turret_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var friction: float = 0.95
@export_range(0.0, 1.0, 0.01) var reverse_multiplier: float = 0.5
@export var is_player: bool = false:
	set(value):
		is_player = value
		if camera and reticle_container:
			camera.enabled = is_player
			reticle_container.visible = is_player
@export var weapons: Dictionary[WeaponSlot, Weapon] = {
	WeaponSlot.PRIMARY: null,
	WeaponSlot.SECONDARY: null,
	WeaponSlot.TERTIARY: null
}
@export var ammo: Dictionary[Weapon.AmmoType, int] = {
	Weapon.AmmoType.SCRAP: 100,
	Weapon.AmmoType.BULLETS: 100,
	Weapon.AmmoType.ROCKETS: 100
}
@export var hull_strength: int = 5

const START_COLOR: Color = Color.WHITE
const END_COLOR: Color = Color.RED

@onready var health: int = max_health:
	set(value):
		health = value
		modulate = START_COLOR.lerp(END_COLOR, 1 - float(health) / float(max_health))
var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.ZERO
var steer_rotation: float = 0:
	set(value):
		turret.rotate(value - steer_rotation)
		steer_rotation = value
		if !rotation_nodes.is_empty() and rotation_nodes.front():
			for node in rotation_nodes:
				node.rotation = steer_rotation
var dead: bool:
	get():
		return health <= 0

# ENGINE
func _ready() -> void:
	is_player = is_player
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
	var collide := move_and_collide(velocity * delta, true)
	if collide:
		if velocity.length() > COLLISION_SPEED:
			damage(COLLISION_DAMAGE, 0)
			velocity = -velocity
			if collide.get_collider() is Vehicle:
				collide.get_collider().damage(COLLISION_DAMAGE, 0)
				collide.get_collider().velocity += -velocity
		else:
			velocity = velocity / 2
	move_and_slide()


# PUBLIC
func fire(event: InputEvent, action: StringName, slot: WeaponSlot):
	if weapons[slot]:
		if event.is_action_pressed(action):
			_on_fire(slot)
			weapon_timers[slot].start(weapons[slot].fire_rate)
		elif event.is_action_released(action):
			weapon_timers[slot].stop()

func damage(value: int, piercing: int):
	health -= max(MINIMUM_DAMAGE, value - max(0, hull_strength - piercing))
	if health <= 0:
		died.emit()
	print("%s:%s HP" % [name, health])


# PRIVATE
func _on_fire(slot: WeaponSlot):
	if weapons[slot]:
		for i in weapons[slot].slugs_per_shot:
			if ammo[weapons[slot].ammo_type] > 0:
				ammo[weapons[slot].ammo_type] -= 1
				var missile: Missile = weapons[slot].ammo_scene.instantiate()
				missile.rotation = (cannon_end.global_position - global_position).angle()
				missile.position = cannon_end.global_position
				add_sibling(missile)
			else:
				print("no ammo")

func _draw_reticle():
	for i in line.size():
		line[i].position = lerp(reticle.position, Vector2.ZERO, float(i) / float(line.size()))

# SIGNALS
func _on_died() -> void:
	modulate = Color.DIM_GRAY
	move_vector = Vector2.ZERO
	aim_vector = Vector2.ZERO
	print("dead")
