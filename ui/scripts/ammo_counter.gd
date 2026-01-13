class_name AmmoCounter extends PanelContainer

@onready var type_label: Label = %TypeLabel
@onready var value_label: Label = %ValueLabel

@export var type: Weapon.AmmoType:
	set(n_value):
		type = n_value
		if type_label:
			type_label.text = str(Weapon.AmmoType.keys()[type])
@export var value: int:
	set(n_value):
		value = n_value
		if value_label:
			value_label.text = str(value)

# ENGINE
func _ready():
	type = type
	value = value


# PUBLIC


# PRIVATE


# SIGNALS
