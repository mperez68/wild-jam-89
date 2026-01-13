class_name Arena extends Node2D

const VEH: Array[PackedScene] = [
	preload("res://game_objects/buggy.tscn"),
	preload("res://game_objects/light_tank.tscn"),
	preload("res://game_objects/heavy_tank.tscn")
]

@onready var spawn_point: Node2D = %SpawnPoint
@onready var hud: Hud = %HUD


# ENGINE
func _ready() -> void:
	var vehicle: Vehicle = VEH.pick_random().instantiate()
	vehicle.is_player = true
	vehicle.position = spawn_point.position
	add_child(vehicle)
	hud.set_player(vehicle)


# PUBLIC


# PRIVATE


# SIGNALS
