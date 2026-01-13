class_name WeaponPanel extends PanelContainer

@onready var slot_label: Label = %SlotLabel
@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var icon_rect: TextureRect = %IconRect
@onready var durability_bar: ProgressBar = %DurabilityBar

@export var slot: Vehicle.WeaponSlot
@export var weapon: Weapon:
	set(value):
		weapon = value
		_update()

# ENGINE
func _ready():
	slot_label.text = Vehicle.WeaponSlot.keys()[slot]


# PUBLIC


# PRIVATE
func _update():
	if !name_label:
		return
	if weapon:
		name_label.text = weapon.display_name
		type_label.text = Weapon.AmmoType.keys()[weapon.ammo_type]
		icon_rect.texture = weapon.icon
		durability_bar.max_value = weapon.starting_durability
		durability_bar.value = weapon.remaining_durability
	else:
		name_label.text = "EMPTY"
		type_label.text = ""
		icon_rect.texture = null
		durability_bar.max_value = 1
		durability_bar.value = 0



# SIGNALS
