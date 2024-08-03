extends RigidBody2D

enum LuggageType {TAPPY, BIGGIE, BAM, OGU}
var luggage_type: LuggageType
var can_be_collected = false
@onready var color_rect = $ColorRect
@onready var power_up_effects = $"/root/PowerUpEffects"

func _ready():
	luggage_type = LuggageType.values()[randi() % LuggageType.size()]
	set_luggage_color()
	print("Luggage initialized with type: ", LuggageType.keys()[luggage_type])
	power_up_effects.connect("luggage_free_for_all_activated", Callable(self, "_on_luggage_free_for_all_activated"))
	power_up_effects.connect("luggage_free_for_all_deactivated", Callable(self, "_on_luggage_free_for_all_deactivated"))

func set_luggage_color():
	var colors = {
		LuggageType.TAPPY: Color.GRAY,
		LuggageType.BIGGIE: Color.RED,
		LuggageType.BAM: Color.LIGHT_BLUE,
		LuggageType.OGU: Color.ORANGE
	}
	color_rect.color = colors[luggage_type]

func _on_luggage_free_for_all_activated():
	color_rect.color = Color.WHITE
	print("Luggage color set to white for Free-For-All")

func _on_luggage_free_for_all_deactivated():
	set_luggage_color()
	print("Luggage color reset to original")
