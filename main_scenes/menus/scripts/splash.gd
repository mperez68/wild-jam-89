class_name Splash extends MenuControl

const MAIN_MENU: PackedScene = preload("res://main_scenes/menus/main_menu.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer


# ENGINE
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_on_animation_player_animation_finished("transition")


# PUBLIC


# PRIVATE


# SIGNALS
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transition":
		SceneManager.new_scene(MAIN_MENU)
