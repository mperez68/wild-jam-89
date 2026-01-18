class_name Arena extends Node2D

const VEH: Array[PackedScene] = [
	preload("res://game_objects/buggy.tscn"),
	preload("res://game_objects/light_tank.tscn"),
	preload("res://game_objects/heavy_tank.tscn")
]
const BIKE: PackedScene = preload("res://game_objects/bike.tscn")

@onready var player_spawn: Node2D = %PlayerSpawn
@onready var hud: Hud = %HUD
@onready var tiled_floor: TileMapLayer = %TiledFloor

var spawn_points: Array[Node2D] = []


# ENGINE
func _ready() -> void:
	for child in tiled_floor.get_children():
		if child is SpawnPoint:
			spawn_points.push_back(child)
	
	_on_player_spawn_request()
	for i in spawn_points.size():
		var bike: Vehicle = BIKE.instantiate()
		bike.position = spawn_points[i].position
		add_child(bike)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_player_spawn_request():
	var vehicle: Vehicle = VEH[0].instantiate()
	vehicle.position = player_spawn.position
	vehicle.is_player = true
	vehicle.respawn.connect(_on_player_spawn_request)
	add_child(vehicle)
	hud.set_player(vehicle)
