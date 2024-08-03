extends CanvasLayer

@onready var main: Control = $Main
@onready var settings: Control = $Settings

func _ready():
	AudioManager.play_bg_music()
	settings.hide()

func _on_play_btn_pressed():
	AudioManager.button_click()
	get_tree().change_scene_to_file("res://src/Nodes/World/main.tscn")

func _on_settings_btn_pressed():
	AudioManager.button_click()
	settings.show()
	main.hide()

func _on_settings_back_btn_pressed():
	AudioManager.button_click()
	settings.hide()
	main.show()

func _on_quit_btn_pressed():
	get_tree().quit()
	
func _on_music_slider_value_changed(value):
	AudioManager.adjust_music_volume(value)

func _on_sfx_slider_value_changed(value):
	AudioManager.adjust_sfx_volume(value)

