extends Control

@onready var camera_2d = $Camera2D

const DEFAULT_POSITION = Vector2(90, 160)
const SETTINGS_POSITION = Vector2(270, 160)

var is_in_settings: bool = false

func _ready():
	AudioManager.play_main_menu_bg_music()
	# Set the initial camera position
	camera_2d.position = DEFAULT_POSITION

func _on_t_settings_btn_pressed():
	AudioManager.button_click()
	if not is_in_settings:
		_move_camera_to_settings()

func _on_back_btn_pressed():
	AudioManager.button_click()
	if is_in_settings:
		_move_camera_to_main()

func _move_camera_to_settings():
	_animate_camera_move(SETTINGS_POSITION)
	is_in_settings = true

func _move_camera_to_main():
	_animate_camera_move(DEFAULT_POSITION)
	is_in_settings = false

func _animate_camera_move(target_position: Vector2):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera_2d, "position", target_position, 0.5)
