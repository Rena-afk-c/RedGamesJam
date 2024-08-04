extends Node2D


@onready var transition_manager = $TransitionManager
@onready var upgrade_manager = $UpgradeManager/UpgradeHud

func _ready():
	transition_manager.fade_out_from_black()
	AudioManager.play_bg_music()

func _on_t_up_btn_pressed():
	AudioManager.button_click()
	upgrade_manager.utilize()
