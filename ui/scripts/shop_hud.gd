class_name ShopHud extends Control

signal shop_closed

@onready var scrap_value_label: Label = %ScrapValueLabel
@onready var bullets_value_label: Label = %BulletsValueLabel
@onready var rockets_value_label: Label = %RocketsValueLabel
@onready var health_label: Label = %HealthLabel
@onready var max_label: Label = %MaxLabel
@onready var craft_grid: GridContainer = %CraftGrid

var vehicle: Vehicle


# ENGINE


# PUBLIC
func set_player(new_vehicle: Vehicle):
	vehicle = new_vehicle
	_update_ammo(vehicle.ammo)
	_update_health(0, vehicle.health)
	vehicle.ammo_changed.connect(_update_ammo)
	vehicle.received_damage.connect(_update_health)
	for child in craft_grid.get_children():
		if child is CraftContainer:
			child.update(new_vehicle)
			child.updated.connect(_update_buttons)

func _update_ammo(ammo: Dictionary[Weapon.AmmoType, int]):
	scrap_value_label.text = str(ammo[Weapon.AmmoType.SCRAP])
	bullets_value_label.text = str(ammo[Weapon.AmmoType.BULLETS])
	rockets_value_label.text = str(ammo[Weapon.AmmoType.ROCKETS])

func _update_health(_received, total: int):
	health_label.text = str(total)
	max_label.text = str(vehicle.max_health)


# PRIVATE
func _update_buttons():
	_update_ammo(vehicle.ammo)
	_update_health(0, vehicle.health)
	for child in craft_grid.get_children():
		if child is CraftContainer:
			child.update(null, false)


# SIGNALS
func _on_return_button_pressed() -> void:
	shop_closed.emit()
