@tool
class_name CraftContainer extends HBoxContainer

signal updated

@onready var craft_button: SfxButton = %CraftButton
@onready var icon_rect: TextureRect = %IconRect
@onready var reward_label: Label = %RewardLabel

@export var cost: int:
	set(value):
		cost = value
		update()
@export var cost_type: Weapon.AmmoType:
	set(value):
		cost_type = value
		update()
@export var reward: int:
	set(value):
		reward = value
		update()
@export var reward_type: Weapon.AmmoType:
	set(value):
		reward_type = value
		update()
@export var healing: int:
	set(value):
		healing = value
		update()
@export var item_reward: Weapon:
	set(value):
		item_reward = value
		update()
@export var item_slot: Vehicle.WeaponSlot:
	set(value):
		item_slot = value
		update()

var player_vehicle: Vehicle


# ENGINE
func _ready():
	update()


# PUBLIC
func update(vehicle: Vehicle = null, emit: bool = true):
	if !craft_button:
		return
	craft_button.text = str("%s\n%s" % [cost, Weapon.AmmoType.keys()[cost_type]])
	if vehicle:
		player_vehicle = vehicle
	if reward > 0:
		reward_label.text = str("%s\n%s" % [reward, Weapon.AmmoType.keys()[reward_type]])
	elif healing > 0:
		reward_label.text = str("%s\nHealing" % [healing])
	else:
		reward_label.text = ""
	if item_reward:
		icon_rect.texture = item_reward.icon
	if player_vehicle and cost <= player_vehicle.ammo[cost_type]:
		craft_button.disabled = false
	else:
		craft_button.disabled = true
	if emit:
		updated.emit()


# PRIVATE


# SIGNALS
func _on_craft_button_pressed() -> void:
	player_vehicle.ammo[cost_type] -= cost
	if reward > 0:
		player_vehicle.ammo[reward_type] += reward
	elif healing > 0:
		player_vehicle.health = min(player_vehicle.max_health, player_vehicle.health + reward)
	elif item_reward:
		var temp: Weapon = player_vehicle.weapons[item_slot]
		player_vehicle.weapons[item_slot] = item_reward
		player_vehicle.ammo[Weapon.AmmoType.SCRAP] += temp.loot_value if temp else 0
	update()
