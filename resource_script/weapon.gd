class_name Weapon extends Resource


enum AmmoType{ SCRAP, BULLETS, ROCKETS }

@export var ammo_scene: PackedScene
@export var ammo_type: AmmoType = AmmoType.SCRAP
@export var slugs_per_shot: int = 5
@export var fire_rate: float = 1.0
@export var starting_durability: int = 500:
	set(value):
		starting_durability = value
		remaining_durability = value
var remaining_durability: int
@export var loot_value: int = 200

@export var display_name: String = "WEAPON"
@export var icon: Texture
