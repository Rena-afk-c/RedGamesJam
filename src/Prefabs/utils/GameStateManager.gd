extends Node

@onready var pause_overlay = $"../../Pause/Pause_Overlay"
@onready var spawner_root = $"../../SpawnerRoot"
@onready var power_up_spawner = $"../../PowerUpSpawner"

func _ready():
	pause_overlay.hide()

func _on_t_pause_btn_pressed():
	AudioManager.button_click()
	pause_overlay.show()
	power_up_spawner.pause_spawner()
	spawner_root.pause_spawner()

func _on_t_resume_btn_pressed():
	AudioManager.button_click()
	pause_overlay.hide()
	power_up_spawner.resume_spawner()
	spawner_root.resume_spawner()
