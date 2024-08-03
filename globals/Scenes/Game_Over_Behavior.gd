extends Control

@onready var root = $Root
@onready var color_rect = $Root/ColorRect
@onready var base = $Root/Base
@onready var score_sprite = $Root/Base/ScoreSprite
@onready var score_label = $Root/Base/ScoreLabel
@onready var ticketsbase = $Root/Ticketsbase
@onready var ticket_sprite = $Root/Ticketsbase/TicketSprie
@onready var ticket_label = $Root/Ticketsbase/TicketLabel
@onready var game_over_sprite = $Root/GameOverSprite
@onready var restart_btn = $Root/RestartBtn
@onready var close_btn = $Root/CloseBtn

var tween: Tween

# Define the final scales
const SCORE_SPRITE_SCALE = Vector2(0.038, 0.038)
const TICKET_SPRITE_SCALE = Vector2(0.038, 0.038)
const GAME_OVER_SPRITE_SCALE = Vector2(0.059, 0.059)
const BTN_SCALE = Vector2(0.057, 0.057)
const BASE_SCALE = Vector2(0.05, 0.05)
const LABEL_SCALE = Vector2(0.8, 0.8)

func _ready():
	# Set initial scales and visibility
	color_rect.modulate.a = 0
	game_over_sprite.scale = Vector2.ZERO
	restart_btn.scale = Vector2.ZERO
	close_btn.scale = Vector2.ZERO
	score_sprite.scale = Vector2.ZERO
	ticket_sprite.scale = Vector2.ZERO
	
	animate_game_over()
	restart_btn.pressed.connect(on_restart_pressed)
	close_btn.pressed.connect(on_close_pressed)

func animate_game_over():
	tween = create_tween().set_parallel()
	# Fade in the background
	tween.tween_property(color_rect, "modulate:a", 1, 0.5)
	# Animate game over sprite
	tween.tween_property(game_over_sprite, "scale", GAME_OVER_SPRITE_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Animate buttons
	tween.tween_property(restart_btn, "scale", BTN_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(close_btn, "scale", BTN_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Animate score and ticket sprites
	tween.tween_property(score_sprite, "scale", SCORE_SPRITE_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(ticket_sprite, "scale", TICKET_SPRITE_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_restart_pressed():
	await get_tree().create_timer(0.15).timeout
	get_tree().reload_current_scene()

func on_close_pressed():
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://src/Nodes/GUI/MainMenu.tscn")


func set_score(score: int):
	score_label.text = str(score)

func set_tickets(tickets: int):
	ticket_label.text = str(tickets)
