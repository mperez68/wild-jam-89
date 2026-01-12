class_name Weapon extends Resource

enum AmmoType{ SCRAP, BULLETS, ROCKETS }

@export var ammo_scene: PackedScene
@export var ammo_type: AmmoType = AmmoType.SCRAP
@export var slugs_per_shot: int = 5
@export var fire_rate: float = 1.0
