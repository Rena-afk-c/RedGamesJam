extends Node

@onready var sfx_audio_player = $SFXAudioPlayer
@onready var music_audio_player = $MusicAudioPlayer
@onready var bg_audio_player = $BgAudioPlayer


const BG_MUSIC = preload("res://assets/audio/bg_music.mp3")
const BUTTON_CLICK = preload("res://assets/audio/button_click.mp3")
const CONVEYOR_BELT = preload("res://assets/audio/conveyor_belt.mp3")
const DROP_LUGGAGE = preload("res://assets/audio/drop_luggage.mp3")
const GAME_OVER = preload("res://assets/audio/game_over.mp3")
const MAIN_MENU_BG = preload("res://assets/audio/main-menu-bg.mp3")
const PICK_UP_LUGGAGE= preload("res://assets/audio/pick_up_luggage.mp3")
const POINT_GAIN = preload("res://assets/audio/point_gain.mp3")
const INCORRECT_OPTION = preload("res://assets/audio/point_lost.mp3")
const PICK_UP_POWER_UP = preload("res://assets/audio/power_up.mp3")
const UPGRADE_NOTI = preload("res://assets/audio/upgrade_noti.mp3")

const MUTED_VOLUME = -40

var is_music_on = true
var is_sfx_on = true

func fade_out_audio(duration: float):
	if is_music_on:
		var tween = create_tween()
		tween.tween_property(music_audio_player, "volume_db", -40, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(bg_audio_player, "volume_db", -40, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func fade_in_audio(duration: float):
	if is_music_on:
		var tween = create_tween()
		tween.tween_property(music_audio_player, "volume_db", 0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
# settings
func toggle_music():
	is_music_on = not is_music_on
	if is_music_on:
		music_audio_player.volume_db = 0
		bg_audio_player.volume_db = 0
	else:
		music_audio_player.volume_db = MUTED_VOLUME
		bg_audio_player.volume_db = MUTED_VOLUME

func toggle_sfx():
	is_sfx_on = not is_sfx_on
	if is_sfx_on:
		sfx_audio_player.volume_db = 0
	else:
		sfx_audio_player.volume_db = MUTED_VOLUME

func play_main_menu_bg_music():
	music_audio_player.stream = MAIN_MENU_BG
	music_audio_player.play()

func play_bg_music():
	bg_audio_player.stream = CONVEYOR_BELT
	bg_audio_player.play()

func stop_bg_music():
	bg_audio_player.stop()
	
func stop_main_menu_bg_music():
	music_audio_player.stop()

# character sfx
func pick_up_luggage_sfx():
	sfx_audio_player.stream = PICK_UP_LUGGAGE
	sfx_audio_player.play()
	
func drop_luggage_sfx():
	sfx_audio_player.stream = DROP_LUGGAGE
	sfx_audio_player.play()
	
# UI sfx
func button_click():
	sfx_audio_player.stream = BUTTON_CLICK
	sfx_audio_player.play()
	
func point_gain_sfx():
	sfx_audio_player.stream = POINT_GAIN
	sfx_audio_player.play()
	
func incorrect_option_sfx():
	sfx_audio_player.stream = INCORRECT_OPTION
	sfx_audio_player.play()
	
func pick_up_powerup_sfx():
	sfx_audio_player.stream = PICK_UP_POWER_UP
	sfx_audio_player.play()

func upgrade_noti():
	sfx_audio_player.stream = UPGRADE_NOTI
	sfx_audio_player.play()
	
func game_over():
	fade_out_audio(3)
	sfx_audio_player.stream = GAME_OVER
	sfx_audio_player.play()
	stop_main_menu_bg_music()
	stop_bg_music()
