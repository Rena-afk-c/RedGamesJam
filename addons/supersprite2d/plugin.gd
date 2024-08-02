@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("SuperSprite2D", "AnimatedSprite2D", preload("res://addons/supersprite2d/AnimatedSprite_m.gd"), null)
	add_custom_type("AnimationFunction", "Resource", preload("res://addons/supersprite2d/Animation_Function.gd"), null)


func _exit_tree():
	remove_custom_type("SuperSprite2D")
	remove_custom_type("AnimationFunction")

