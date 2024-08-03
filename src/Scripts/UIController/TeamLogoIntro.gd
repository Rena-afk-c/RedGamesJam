extends Control

@onready var bg = $BG
@onready var team_logo = $TeamLogo
@onready var rena_label = $RenaLabel
@onready var game_by_label = $GameByLabel
@onready var team_label = $TeamLabel

func _ready():
	setup_intro_animation()

func setup_intro_animation():
	# Hide all elements initially
	game_by_label.modulate.a = 0
	team_label.modulate.a = 0
	team_logo.modulate.a = 0
	rena_label.modulate.a = 0
	
	# Set initial positions for animations
	team_logo.position.y += 50
	rena_label.position.y += 50
	
	var tween = create_tween()
	
	# Fade in and out "Game By" label
	tween.tween_property(game_by_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(game_by_label, "modulate:a", 0.0, 0.5)
	
	# Fade in and out Team label (faster)
	tween.tween_property(team_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(team_label, "modulate:a", 0.0, 0.5)
	
	# Fade in and animate Team Logo and Rena Label
	tween.parallel().tween_property(team_logo, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(team_logo, "position:y", team_logo.position.y - 50, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(rena_label, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(rena_label, "position:y", rena_label.position.y - 50, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Pause for a moment
	tween.tween_interval(1.0)
	

	# Pause for a moment
	tween.tween_interval(0.5)
	
	# Fade out all elements with a slight upward movement
	tween.parallel().tween_property(team_logo, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(team_logo, "position:y", team_logo.position.y - 20, 0.5)
	tween.parallel().tween_property(rena_label, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(rena_label, "position:y", rena_label.position.y - 20, 0.5)
	
	# Change scene after animation is complete
	tween.tween_callback(change_scene)


func change_scene():
	get_tree().change_scene_to_file("res://src/Nodes/GUI/MainMenu.tscn")
