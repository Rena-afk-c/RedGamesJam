extends Node
enum Characters {TAPPY, BIGGIE, BAM, OGU}

var selected_character: Characters = Characters.TAPPY  
var currency_flight: int = 0

signal character_selected(character: Characters)
signal currency_updated(new_amount: int)

func _ready():
	print("GameManager initialized. Default character: ", Characters.keys()[selected_character])

func select_character(character: Characters):
	selected_character = character
	character_selected.emit(character)
	print("Character selected in GameManager: ", Characters.keys()[selected_character])

func get_selected_character() -> Characters:
	return selected_character

func collect_luggage():
	currency_flight += 5
	currency_updated.emit(currency_flight)
	print("Luggage collected. New currency: ", currency_flight)
