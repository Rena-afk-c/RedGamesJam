extends CanvasLayer

@onready var main: Control = $Main
@onready var settings: Control = $Settings
func _ready():
	settings.hide()

func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://src/Nodes/World/main.tscn")

func _on_settings_btn_pressed():
	settings.show()
	main.hide()

func _on_settings_back_btn_pressed():
	settings.hide()
	main.show()

func _on_quit_btn_pressed():
	get_tree().quit()
