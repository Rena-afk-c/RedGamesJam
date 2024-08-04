extends Node

@onready var game_logo = $"../Background/GameLogo"
@onready var air_asialogo = $"../Background/AirAsialogo"
@onready var t_play_btn = $"../Main/BtnContainer/TPlayBtn"
@onready var t_settings_btn = $"../Main/BtnContainer/TSettingsBtn"
@onready var t_close_btn = $"../Main/BtnContainer/TCloseBtn"
@onready var t_daily_gift_btn = $"../GiftHud/GiftPanel/TDailyGiftBtn"
@onready var TransitionManager = $"../TransitionManager"

var buttons: Array
var logos: Array
const BUTTON_PRESS_SCALE_FACTOR = 0.9
const BUTTON_IDLE_SCALE_FACTOR = 1.05
const LOGO_ROTATION_DEGREES = 2
const SCENE_TRANSITION_DELAY = 0.3

func _ready():
	buttons = [t_play_btn, t_settings_btn, t_close_btn, t_daily_gift_btn]
	logos = [game_logo, air_asialogo]
	TransitionManager.fade_in()
	
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
		start_idle_animation(button)
	
	for logo in logos:
		start_logo_idle_animation(logo)
	
	# Connect the play button pressed signal
	#t_play_btn.pressed.connect(_on_t_play_btn_pressed)

func _on_button_pressed(button):
	var original_scale = button.scale
	var press_scale = original_scale * BUTTON_PRESS_SCALE_FACTOR
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", press_scale, 0.1)
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.1)
	tween.chain().tween_property(button, "scale", original_scale, 0.1)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.1)

func start_idle_animation(button):
	var original_scale = button.scale
	var max_scale = original_scale * BUTTON_IDLE_SCALE_FACTOR
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(button, "scale", max_scale, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "scale", original_scale, 1.0).set_trans(Tween.TRANS_SINE)
	
	button.set_meta("idle_tween", tween)

func start_logo_idle_animation(logo):
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(logo, "rotation_degrees", LOGO_ROTATION_DEGREES, 2.0).set_trans(Tween.TRANS_SINE)
	rotation_tween.tween_property(logo, "rotation_degrees", -LOGO_ROTATION_DEGREES, 2.0).set_trans(Tween.TRANS_SINE)
	
	logo.set_meta("rotation_tween", rotation_tween)
	
	var color_tween = create_tween()
	color_tween.set_loops()
	color_tween.tween_property(logo, "modulate", Color(1.2, 1.2, 1.2), 1.5).set_trans(Tween.TRANS_SINE)
	color_tween.tween_property(logo, "modulate", Color(1, 1, 1), 1.5).set_trans(Tween.TRANS_SINE)
	
	logo.set_meta("color_tween", color_tween)

func _on_t_play_btn_pressed():
	AudioManager.button_click()
	AudioManager.fade_out_audio(1.0)
	TransitionManager.transition("res://src/Nodes/World/main_2.tscn", TransitionManager.TransitionType.ICON_AND_TEXT)




func _on_play_button_animation_finished():
	TransitionManager.chan

func _on_t_close_btn_pressed():
	get_tree().quit()

func stop_all_tweens():
	for button in buttons:
		if button.has_meta("idle_tween"):
			button.get_meta("idle_tween").kill()
	
	for logo in logos:
		if logo.has_meta("rotation_tween"):
			logo.get_meta("rotation_tween").kill()
		if logo.has_meta("color_tween"):
			logo.get_meta("color_tween").kill()
