class_name Arena extends Node2D

const VEH: Array[PackedScene] = [
	preload("res://game_objects/buggy.tscn"),
	preload("res://game_objects/light_tank.tscn"),
	preload("res://game_objects/heavy_tank.tscn")
]
const BIKE: PackedScene = preload("res://game_objects/bike.tscn")

@onready var player_spawn: Node2D = %PlayerSpawn
@onready var spawn_points_holder: Node2D = %SpawnPoints
@onready var hud: Hud = %HUD

var spawn_points: Array[Node2D] = []


# ENGINE
func _ready() -> void:
	for child in spawn_points_holder.get_children():
		spawn_points.push_back(child)
	
	var vehicle: Vehicle = VEH[0].instantiate()#VEH.pick_random().instantiate()
	vehicle.position = player_spawn.position
	vehicle.is_player = true
	add_child(vehicle)
	hud.set_player(vehicle)
	
	for i in spawn_points.size():
		var bike: Vehicle = BIKE.instantiate()
		bike.position = spawn_points[i].position
		add_child(bike)


# PUBLIC


# PRIVATE


# SIGNALS
