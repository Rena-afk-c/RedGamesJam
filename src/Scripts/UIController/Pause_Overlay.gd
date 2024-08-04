extends Control

@onready var t_resume_btn = $ResumeBase/Panel/TResumeBtn
@onready var t_menu_btn = $MenuBase/Panel/TMenuBtn
@onready var pause_icon = $Sprite2D
@onready var bg = $BG
@onready var icons = $BG/ICONS
@onready var TransitionManager = $"../../TransitionManager"

const BUTTON_SCALE_FACTOR = 0.9
const ICON_FLOAT_DISTANCE = 10
const ICON_FLOAT_DURATION = 2.0
const BUTTON_ANIMATION_DURATION = 0.1
const SCENE_TRANSITION_DELAY = 0.2  # Delay before changing scene

var initial_icon_position: Vector2

func _ready():
	setup_button_connections()
	initial_icon_position = pause_icon.position
	start_pause_icon_animation()
	start_floating_icons_animation()

func setup_button_connections():
	t_menu_btn.pressed.connect(_on_t_menu_btn_pressed)

func start_pause_icon_animation():
	var tween = create_tween()
	tween.set_loops()  # Make the tween repeat indefinitely
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Move up
	tween.tween_property(pause_icon, "position:y", 
		initial_icon_position.y - ICON_FLOAT_DISTANCE, 
		ICON_FLOAT_DURATION * 0.5)
	
	# Move down
	tween.tween_property(pause_icon, "position:y", 
		initial_icon_position.y + ICON_FLOAT_DISTANCE, 
		ICON_FLOAT_DURATION)
	
	# Move back to center
	tween.tween_property(pause_icon, "position:y", 
		initial_icon_position.y, 
		ICON_FLOAT_DURATION * 0.5)

func start_floating_icons_animation():
	for icon in icons.get_children():
		animate_floating_icon(icon)

func animate_floating_icon(icon: Node2D):
	var tween = create_tween()
	tween.set_loops()  # Make the tween repeat indefinitely
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Random movement
	var random_offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	tween.tween_property(icon, "position", 
		icon.position + random_offset, 
		randf_range(3.0, 5.0))
	tween.tween_property(icon, "position", 
		icon.position, 
		randf_range(3.0, 5.0))
	
	# Random rotation
	var random_rotation = randf_range(-0.2, 0.2)
	tween.parallel().tween_property(icon, "rotation", 
		icon.rotation + random_rotation, 
		randf_range(2.0, 4.0))
	tween.tween_property(icon, "rotation", 
		icon.rotation, 
		randf_range(2.0, 4.0))
	
	# Random scaling
	var random_scale = randf_range(0.9, 1.1)
	tween.parallel().tween_property(icon, "scale", 
		icon.scale * random_scale, 
		randf_range(2.0, 3.0))
	tween.tween_property(icon, "scale", 
		icon.scale, 
		randf_range(2.0, 3.0))

func _on_t_menu_btn_pressed():
	AudioManager.button_click()
	AudioManager.fade_out_audio(1.5)
	animate_button_press(t_menu_btn)
	await get_tree().create_timer(SCENE_TRANSITION_DELAY).timeout
	TransitionManager.transition("res://src/Nodes/GUI/MainMenu.tscn", TransitionManager.TransitionType.ICON_AND_TEXT)

func animate_button_press(button: TouchScreenButton):
	var original_scale = button.scale
	var impact_scale = original_scale * BUTTON_SCALE_FACTOR
	
	var tween = create_tween()
	tween.tween_property(button, "scale", impact_scale, BUTTON_ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", original_scale, BUTTON_ANIMATION_DURATION).set_ease(Tween.EASE_IN)
