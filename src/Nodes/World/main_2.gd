extends Node2D
#
#
#@onready var transition_manager = $TransitionManager
@onready var upgrade_manager = $UpgradeManager/UpgradeHud
#@onready var spawner_root = $SpawnerRoot

func _ready():
	#transition_manager.fade_out_from_black()
	AudioManager.fade_in_audio(1.0)
	AudioManager.play_main_menu_bg_music()
	AudioManager.play_bg_music()
#
func _on_t_up_btn_pressed():
	AudioManager.button_click()
	upgrade_manager.utilize()
