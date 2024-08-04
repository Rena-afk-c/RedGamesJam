extends Control

@onready var back_btn = $BackBtn
@onready var settings_logo = $SettingsLogo
@onready var music_btn = $Base/MusicBtn
@onready var sfx_btn = $Base/SfxBtn

var music_enabled = true
var sfx_enabled = true

func _ready():
	animate_logo()

func _on_music_btn_pressed():
	AudioManager.toggle_music()

func _on_sfx_btn_pressed():
	AudioManager.toggle_sfx()
	
func animate_logo():
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var start_y = settings_logo.position.y
	var offset = 10 
	tween.tween_property(settings_logo, "position:y", start_y - offset, 1.0)
	tween.tween_property(settings_logo, "position:y", start_y + offset, 1.0)
	tween.tween_property(settings_logo, "position:y", start_y, 1.0)
