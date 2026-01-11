@tool
class_name Reticle extends Control

@onready var texture_rect: TextureRect = %TextureRect

@export var img_scale: Vector2 = Vector2.ONE:
	set(value):
		img_scale = value
		if texture_rect:
			texture_rect.scale = img_scale


# ENGINE
func _ready():
	img_scale = img_scale


# PUBLIC


# PRIVATE


# SIGNALS
