class_name Shop extends Area2D

signal show_shop(show: bool)

# ENGINE


# PUBLIC


# PRIVATE


# SIGNALS



func _on_body_entered(body: Node2D) -> void:
	if body is Vehicle and body.is_player:
		show_shop.emit(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Vehicle and body.is_player:
		show_shop.emit(true)
