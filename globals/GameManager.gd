extends Node

enum Characters {TAPPY, BIGGIE, BAM, OGU}

var selected_character: Characters = Characters.TAPPY  
var currency_flight: int = 0
var tickets: int = 0
var current_point_multiplier: float = 1.0
var combo_score: int = 0
var high_score: int = 0
var luggage_count: int = 0
var max_luggage: int = 20  
var GAME_PAUSED: bool = false
var power_up_used: bool = false

signal character_selected(character: Characters)
signal currency_updated(new_amount: int)
signal high_score_updated(new_high_score: int)
signal ticket_collected(new_ticket_count: int)
signal combo_updated(new_combo: int)
signal game_over
signal game_paused(is_paused: bool)

@onready var power_up_effects = $"/root/PowerUpEffects"

func _ready():
	print("GameManager initialized. Default character: ", Characters.keys()[selected_character])
	power_up_effects.connect("point_frenzy_activated", Callable(self, "_on_point_frenzy_activated"))
	power_up_effects.connect("point_frenzy_deactivated", Callable(self, "_on_point_frenzy_deactivated"))
	load_high_score()
	high_score = 0

func increment_luggage_count():
	luggage_count += 1
	check_end_game_condition()

func decrement_luggage_count():
	luggage_count -= 1

func check_end_game_condition():
	if luggage_count >= max_luggage:
		emit_signal("game_over")

func restart_game():
	luggage_count = 0
	currency_flight = 0
	tickets = 0
	combo_score = 0
	current_point_multiplier = 1.0
	power_up_used = false
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()

func select_character(character: Characters):
	selected_character = character
	character_selected.emit(character)
	print("Character selected in GameManager: ", Characters.keys()[selected_character])

func get_selected_character() -> Characters:
	return selected_character

func collect_luggage():
	AudioManager.point_gain_sfx()
	ParticleManager.create_exploding_particle()
	var base_value = 5
	var collected_value = int(base_value * current_point_multiplier)
	currency_flight += collected_value
	currency_updated.emit(currency_flight)
	print("Luggage collected. Value: ", collected_value, " New currency: ", currency_flight)
	increment_combo()
	check_high_score()

func collect_ticket():
	tickets += 1
	ticket_collected.emit(tickets)
	print("Ticket collected. Total tickets: ", tickets)

func increment_combo():
	combo_score += 1
	combo_updated.emit(combo_score)

func reset_combo():
	combo_score = 0
	combo_updated.emit(combo_score)

func _on_point_frenzy_activated(multiplier):
	current_point_multiplier = multiplier
	print("Point multiplier set to: ", current_point_multiplier)

func _on_point_frenzy_deactivated():
	current_point_multiplier = 1.0
	print("Point multiplier reset to: ", current_point_multiplier)

func check_high_score():
	if currency_flight > high_score:
		high_score = currency_flight
		high_score_updated.emit(high_score)
		save_high_score()

func save_high_score():
	var save_game = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	save_game.store_line(str(high_score))

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var save_game = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = int(save_game.get_line())

func toggle_pause():
	GAME_PAUSED = !GAME_PAUSED
	get_tree().paused = GAME_PAUSED
	game_paused.emit(GAME_PAUSED)

func use_power_up(power_up_type: String):
	power_up_used = true
	# Implement power-up logic here
	print("Power-up used: ", power_up_type)

func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
