extends CanvasLayer

@onready var GameOver: Control = $GameOver
@onready var Pause: Control = $Pause

func _ready():
	GameOver.show()
	Pause.hide()

# TODO: show pause UI when click button in main scene

func _on_restart_btn_pressed():
	GameOver.hide()
	get_tree().change_scene_to_file("res://src/Nodes/World/main.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_resume_btn_pressed():
	pass # resume the game

func _on_pause_quit_btn_pressed():
	get_tree().quit()
#
