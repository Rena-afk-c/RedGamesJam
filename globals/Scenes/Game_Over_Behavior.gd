extends Control

@onready var root = $Root
@onready var color_rect = $Root/ColorRect
@onready var base = $Root/Base
@onready var score_label = $Root/Base/ScoreLabel
@onready var ticketsbase = $Root/Ticketsbase
@onready var ticket_label = $Root/Ticketsbase/TicketLabel
@onready var game_over_sprite = $Root/GameOverSprite
@onready var restart_btn = $Root/RestartBtn
@onready var close_btn = $Root/CloseBtn
@onready var spawner_root = $"../SpawnerRoot"
@onready var power_up_spawner = $"../PowerUpSpawner"
@onready var duration_bars = $"../HUD/DurationBars"
@onready var score_ticket_display = $"../HUD/Score+Ticket_Display"
@onready var t_pause_btn = $"../HUD/TPauseBtn"
@onready var t_up_btn = $"../HUD/TUpBtn"

var tween: Tween

# Define the final scales
const SCORE_SPRITE_SCALE = Vector2(0.038, 0.038)
const TICKET_SPRITE_SCALE = Vector2(0.038, 0.038)
const GAME_OVER_SPRITE_SCALE = Vector2(0.059, 0.059)
const BTN_SCALE = Vector2(0.057, 0.057)
const BASE_SCALE = Vector2(0.05, 0.05)
const LABEL_SCALE = Vector2(0.8, 0.8)

func _ready():
	# Set the Control node (self) to ignore mouse events
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Set initial scales and visibility
	color_rect.modulate.a = 0
	game_over_sprite.scale = Vector2.ZERO
	restart_btn.scale = Vector2.ZERO
	close_btn.scale = Vector2.ZERO
	ticketsbase.hide()
	base.hide()
	
	# Disable buttons initially
	restart_btn.visible = false
	close_btn.visible = false
	
	restart_btn.pressed.connect(on_restart_pressed)
	close_btn.pressed.connect(on_close_pressed)

func hide_btn():
	t_pause_btn.hide()
	t_up_btn.hide()

func Game_Over_Utilize(final_score: int, final_tickets: int):
	AudioManager.game_over()
	set_score(final_score)
	set_tickets(final_tickets)
	animate_game_over()
	ticketsbase.show()
	base.show()
	spawner_root.pause_spawner()
	power_up_spawner.pause_spawner()
	duration_bars.hide()
	score_ticket_display.hide()
	hide_btn()
	
	# Enable touch input for the entire Control when game over screen is shown
	mouse_filter = Control.MOUSE_FILTER_STOP

func animate_game_over():
	tween = create_tween().set_parallel()
	# Fade in the background
	tween.tween_property(color_rect, "modulate:a", 1, 0.5)
	# Animate game over sprite
	tween.tween_property(game_over_sprite, "scale", GAME_OVER_SPRITE_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Animate buttons
	tween.tween_property(restart_btn, "scale", BTN_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(close_btn, "scale", BTN_SCALE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Make buttons visible after animation
	tween.tween_callback(func(): 
		restart_btn.visible = true
		close_btn.visible = true
	)

func on_restart_pressed():
	await get_tree().create_timer(0.15).timeout
	get_tree().reload_current_scene()

func on_close_pressed():
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://src/Nodes/GUI/MainMenu.tscn")

func set_score(score: int):
	score_label.text = "Score: " +  str(score)

func set_tickets(tickets: int):
	ticket_label.text = "Tickets: " + str(tickets)
