extends Node2D


@onready var transition_manager = $TransitionManager
@onready var upgrade_manager = $UpgradeManager/UpgradeHud
@onready var score_label = $ScoreLabel

func _ready():
	transition_manager.fade_out_from_black()


func _on_t_up_btn_pressed():
	upgrade_manager.utilize()
