extends Node

@onready var sfx_audio_player = $SFXAudioPlayer
@onready var music_audio_player = $MusicAudioPlayer
@onready var bg_audio_player = $BgAudioPlayer

const BG_MUSIC = preload("res://assets/audio/bg_music.mp3")
const BUTTON_CLICK = preload("res://assets/audio/button_click.mp3")
const CONVEYOR_BELT = preload("res://assets/audio/conveyor_belt.mp3")
const DROP_LUGGAGE = preload("res://assets/audio/drop_luggage.mp3")
const GAME_OVER = preload("res://assets/audio/game_over.mp3")
const PICK_UP_LUGGAGE= preload("res://assets/audio/pick_up_luggage.mp3")
const POINT_GAIN = preload("res://assets/audio/point_gain.mp3")
const POINT_LOST = preload("res://assets/audio/point_lost.mp3")
const PICK_UP_POWER_UP = preload("res://assets/audio/power_up.mp3")
const UPGRADE_NOTI = preload("res://assets/audio/upgrade_noti.mp3")


var pitch_scale_speed = 1.0

func play_bg_music():
	music_audio_player.stream = BG_MUSIC
	music_audio_player.play()
	bg_audio_player.stream = CONVEYOR_BELT
	bg_audio_player.play()

func stop_bg_music():
	music_audio_player.stop()
	bg_audio_player.stop()

# settings
func adjust_music_volume(value):
	music_audio_player.volume_db = value - 40
	bg_audio_player.volume_db = value - 40
	
func adjust_sfx_volume(value):
	sfx_audio_player.volume_db = value - 40
	
# when luggage spawns faster 
func increase_bg_music_pace():
	pitch_scale_speed += 0.05
	music_audio_player.pitch_scale = pitch_scale_speed
	
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
	sfx_audio_player.seek(0.26)
	sfx_audio_player.play()
	
func point_gain_sfx():
	sfx_audio_player.stream = POINT_GAIN
	sfx_audio_player.play()
	
func point_lost_sfx():
	sfx_audio_player.stream = POINT_LOST
	sfx_audio_player.play()
	
func pick_up_powerup_sfx():
	sfx_audio_player.stream = PICK_UP_POWER_UP
	sfx_audio_player.play()

func upgrade_noti():
	sfx_audio_player.stream = UPGRADE_NOTI
	sfx_audio_player.play()
	
func game_over():
	sfx_audio_player.stream = GAME_OVER
	sfx_audio_player.play()
	stop_bg_music()
