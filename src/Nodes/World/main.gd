extends Node2D
@onready var transition_manager = $TransitionManager


func _ready():
	transition_manager.fade_out()
