@tool
class_name Pickup extends Area2D

enum Type{ SCRAP, BULLETS, ROCKETS, REPAIR }

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var spawn_particles: CPUParticles2D = %SpawnParticles
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var type: Type = Type.SCRAP:
	set(value):
		type = value
		if sprite_2d:
			var new_texture: Texture
			match type:
				Type.SCRAP:
					new_texture = scrap_texture
				Type.BULLETS:
					new_texture = bullets_texture
				Type.ROCKETS:
					new_texture = rockets_texture
				Type.REPAIR:
					new_texture = repair_texture
			sprite_2d.texture = new_texture
@export var value: int = 50
@export_category("Textures")
@export var scrap_texture: Texture
@export var bullets_texture: Texture
@export var rockets_texture: Texture
@export var repair_texture: Texture


# ENGINE
func _ready():
	type = type
	rotation_degrees = randf_range(0, 359)
	spawn_particles.emitting = true


# PUBLIC


# PRIVATE


# SIGNALS
func _on_body_entered(body: Node2D) -> void:
	if body is Vehicle and body.is_player:
		match type:
			Type.SCRAP:
				body.ammo[Weapon.AmmoType.SCRAP] += value
			Type.BULLETS:
				body.ammo[Weapon.AmmoType.BULLETS] += value
			Type.ROCKETS:
				body.ammo[Weapon.AmmoType.ROCKETS] += value
			Type.REPAIR:
				body.health = min(body.max_health, body.health + value)
		body.ammo_changed.emit(body.ammo)
		spawn_particles.emitting = true
		animation_player.play("pickup")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pickup":
		queue_free()
