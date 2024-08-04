extends Node


@onready var pause_overlay = $"../../Pause/Pause_Overlay"

var pause_state:bool = false

func _ready():
	pause_overlay.hide()

func _on_t_pause_btn_pressed():
	AudioManager.button_click()
	pause_overlay.show()
	pause_state = true

func _on_t_resume_btn_pressed():
	AudioManager.button_click()
	pause_overlay.hide()
	pause_state = false
