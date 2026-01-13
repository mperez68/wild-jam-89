class_name Hud extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var counters: Array[AmmoCounter] = [ %ScrapCount, %BulletCount, %RocketCount ]
@onready var health_label: Label = %HealthLabel
@onready var max_label: Label = %MaxLabel
@onready var weapon_panels: Dictionary[Vehicle.WeaponSlot, WeaponPanel] = {
	Vehicle.WeaponSlot.PRIMARY: %PrimaryPanel, 
	Vehicle.WeaponSlot.SECONDARY: %SecondaryPanel,
	Vehicle.WeaponSlot.TERTIARY: %TertiaryPanel
}
@onready var game_hud: Control = %GameHud
@onready var game_menu: CenterContainer = %GameMenu

var player_vehicle: Vehicle


# ENGINE


# PUBLIC
func set_player(vehicle: Vehicle):
	player_vehicle = vehicle
	health_bar.value = vehicle.health
	health_label.text = str(vehicle.health)
	health_bar.max_value = vehicle.max_health
	max_label.text = str(vehicle.max_health)
	player_vehicle.received_damage.connect(_on_received_damage)
	player_vehicle.ammo_changed.connect(_on_ammo_changed)
	player_vehicle.weapons_changed.connect(_on_weapons_changed)
	_on_ammo_changed(player_vehicle.ammo)
	_on_weapons_changed(player_vehicle.weapons)


# PRIVATE
func _on_received_damage(_received: int, total: int):
	health_label.text = str(total)
	health_bar.value = total

func _on_ammo_changed(ammo_store: Dictionary[Weapon.AmmoType, int]):
	for counter in counters:
		counter.value = ammo_store[counter.type]

func _on_weapons_changed(weapons: Dictionary[Vehicle.WeaponSlot, Weapon]):
	for key in weapons.keys():
		weapon_panels[key].weapon = weapons[key]


# SIGNALS


func _on_menu_button_pressed(show_menu: bool) -> void:
	get_tree().paused = show_menu
	game_hud.visible = !show_menu
	game_menu.visible = show_menu
