extends Control

@onready var animation_player = $ColorRect/AnimationPlayer

func fade_in():
	animation_player.play("fade_in")
	
func fade_out():
	animation_player.play("fade_out")
