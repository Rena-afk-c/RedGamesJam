extends Node
enum Characters {TAPPY, BIGGIE, BAM, OGU}

var selected_character: Characters = Characters.TAPPY  
var currency_flight: int = 0
var current_point_multiplier: float = 1.0

signal character_selected(character: Characters)
signal currency_updated(new_amount: int)

var power_up_used:bool = false

@onready var power_up_effects = $"/root/PowerUpEffects"

func _ready():
	print("GameManager initialized. Default character: ", Characters.keys()[selected_character])
	power_up_effects.connect("point_frenzy_activated", Callable(self, "_on_point_frenzy_activated"))
	power_up_effects.connect("point_frenzy_deactivated", Callable(self, "_on_point_frenzy_deactivated"))

func select_character(character: Characters):
	selected_character = character
	character_selected.emit(character)
	print("Character selected in GameManager: ", Characters.keys()[selected_character])

func get_selected_character() -> Characters:
	return selected_character

func collect_luggage():
	var base_value = 5
	var collected_value = int(base_value * current_point_multiplier)
	currency_flight += collected_value
	currency_updated.emit(currency_flight)
	print("Luggage collected. Value: ", collected_value, " New currency: ", currency_flight)

func _on_point_frenzy_activated(multiplier):
	current_point_multiplier = multiplier
	print("Point multiplier set to: ", current_point_multiplier)

func _on_point_frenzy_deactivated():
	current_point_multiplier = 1.0
	print("Point multiplier reset to: ", current_point_multiplier)
