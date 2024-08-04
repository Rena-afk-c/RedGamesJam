extends CanvasLayer

@onready var GameOver: Control = $GameOver
@onready var Pause: Control = $Pause

func _ready():
	AudioManager.game_over()
	GameOver.show()
	Pause.hide()

func _on_restart_btn_pressed():
	AudioManager.button_click()
	GameOver.hide()
	get_tree().change_scene_to_file("res://src/Nodes/World/main.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_resume_btn_pressed():
	AudioManager.button_click()
	pass # resume the game

func _on_pause_quit_btn_pressed():
	get_tree().quit()
#
