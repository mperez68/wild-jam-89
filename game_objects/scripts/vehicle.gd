class_name Vehicle extends CharacterBody2D

signal died
signal received_damage(received: int, total: int)
signal ammo_changed(ammo_store: Dictionary[Weapon.AmmoType, int])
signal weapons_changed(weapons: Dictionary[WeaponSlot, Weapon])

enum WeaponSlot{ PRIMARY, SECONDARY, TERTIARY }

const COLLISION_DAMAGE: int = 10
#const COLLISION_SPEED: float = 150.0
const MINIMUM_DAMAGE: int = 1

@onready var shoot_sfx: AudioStreamPlayer2D = %ShootSfx
@onready var damage_sfx: AudioStreamPlayer2D = %DamageSfx
@onready var scrap_sfx: AudioStreamPlayer2D = %ScrapSfx

@onready var turret: Node2D = %Turret
@onready var camera: Camera2D = %Camera
@onready var reticle: Control = %Reticle
@onready var aim_target: Reticle = %AimTarget
@onready var cannon_end: Node2D = %CannonEnd
@onready var reticle_container: Control = %ReticleContainer
@onready var nav: NavigationAgent2D = %NavigationAgent2D
@onready var line: Array[Control] = [ %Reticle, %Line, %Line2, %Line3 ]
@onready var rotation_nodes: Array[Node] = [ %Sprite2D, %CollisionPolygon2D, %CameraHolder,
											%Reticle, %Line, %Line2, %Line3 ]
@onready var weapon_timers: Dictionary[WeaponSlot, Timer] = {
	WeaponSlot.PRIMARY: %PrimaryWeaponTimer,
	WeaponSlot.SECONDARY: %SecondaryWeaponTimer,
	WeaponSlot.TERTIARY: %TertiaryWeaponTimer
}
@onready var health: int = max_health:
	set(value):
		received_damage.emit(value - health, value)
		health = value
		modulate = START_COLOR.lerp(END_COLOR, 1 - float(health) / float(max_health))

@export_range(1, 150, 1.0, "or_greater") var max_health: int = 100
@export var speed: float = 500.0
@export_range(0, 90, 0.1, "or_greater") var rotate_speed: float = 1.4
@export_range(0, 90, 0.1, "or_greater") var turret_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var friction: float = 0.95
@export_range(0.0, 1.0, 0.01) var reverse_multiplier: float = 0.5
@export var hull_strength: int = 5
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

const START_COLOR: Color = Color.WHITE
const END_COLOR: Color = Color.RED

var locked: bool = false
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
var targets: Array[Vehicle] = []
var rally_points: Array[Vector2] = []


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
	var _collide := move_and_collide(velocity * delta, true)
	#if collide:
		#if velocity.length() > COLLISION_SPEED:
			#damage(COLLISION_DAMAGE, 0)
			#velocity = -velocity
			#if collide.get_collider() is Vehicle:
				#collide.get_collider().damage(COLLISION_DAMAGE, 0)
				#collide.get_collider().velocity += -velocity
		#else:
			#velocity = velocity / 2
	move_and_slide()


# PUBLIC
func fire(event: InputEvent, action: StringName, slot: WeaponSlot):
	if weapons[slot]:
		if event.is_action_pressed(action):
			_on_fire(slot)
			if weapons[slot]:
				weapon_timers[slot].start(weapons[slot].fire_rate)
		elif event.is_action_released(action):
			weapon_timers[slot].stop()

func damage(value: int, piercing: int):
	var total_damage: int = max(MINIMUM_DAMAGE, value - max(0, hull_strength - piercing))
	health -= total_damage
	if health <= 0:
		died.emit()
	damage_sfx.play()

func fire_all(start: bool = true):
	for key in weapons.keys():
		if weapons[key]:
			if start and weapon_timers[key].is_stopped():
				print(weapon_timers[key].is_stopped())
				weapon_timers[key].start(weapons[key].fire_rate)
				_on_fire(key)
			elif !start:
				weapon_timers[key].stop()


# PRIVATE
func _on_fire(slot: WeaponSlot):
	if weapons[slot]:
		for i in weapons[slot].slugs_per_shot:
			if ammo[weapons[slot].ammo_type] > 0:
				weapons[slot].remaining_durability -= 1
				ammo[weapons[slot].ammo_type] -= 1
				var missile: Missile = weapons[slot].ammo_scene.instantiate()
				missile.rotation = (cannon_end.global_position - global_position).angle()
				missile.position = cannon_end.global_position
				add_sibling(missile)
				shoot_sfx.play()
			else:
				weapon_timers[slot].stop()
				print("no ammo")
		if weapons[slot].remaining_durability <= 0:
			ammo[Weapon.AmmoType.SCRAP] += weapons[slot].loot_value
			weapons[slot] = null
			scrap_sfx.play()
		weapons_changed.emit(weapons)
		ammo_changed.emit(ammo)

func _collect_item(_pickup: Node):
	weapons_changed.emit(weapons)

func _draw_reticle():
	for i in line.size():
		line[i].position = lerp(reticle.position, Vector2.ZERO, float(i) / float(line.size()))


const PICKUP: PackedScene = preload("res://game_objects/pickup.tscn")

# SIGNALS
func _on_died() -> void:
	modulate = Color.DIM_GRAY
	move_vector = Vector2.ZERO
	aim_vector = Vector2.ZERO
	call_deferred("on_died_deferred")

func on_died_deferred() -> void:
	%CollisionPolygon2D.disabled = true
	var pickup: Pickup = PICKUP.instantiate()
	var rnd: Weapon.AmmoType = ammo.keys().pick_random()
	if ammo[rnd] <= 0:
		rnd = Weapon.AmmoType.SCRAP
	pickup.position = position
	match rnd:
		Weapon.AmmoType.SCRAP:
			pickup.type = pickup.Type.SCRAP
			pickup.value = ammo[rnd]
		Weapon.AmmoType.BULLETS:
			pickup.type = pickup.Type.BULLETS
			pickup.value = ammo[rnd]
		Weapon.AmmoType.ROCKETS:
			pickup.type = pickup.Type.ROCKETS
			pickup.value = ammo[rnd]
	if pickup.value > 0:
		add_sibling(pickup)
	locked = true

func _on_aggro_radius_body(body: Node2D, entered: bool) -> void:
	if body is Vehicle and body != self:
		if entered:
			targets.push_back(body)
		else:
			targets.erase(body)
