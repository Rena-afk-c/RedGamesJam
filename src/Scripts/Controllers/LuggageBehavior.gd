extends RigidBody2D

enum LuggageType {TAPPY, BIGGIE, BAM, OGU}
var luggage_type: LuggageType
var can_be_collected = false
@onready var color_rect = $ColorRect

func _ready():
	luggage_type = LuggageType.values()[randi() % LuggageType.size()]
	set_luggage_color()
	print("Luggage initialized")

func set_luggage_color():
	var colors = {
		LuggageType.TAPPY: Color.GRAY,
		LuggageType.BIGGIE: Color.RED,
		LuggageType.BAM: Color.LIGHT_BLUE,
		LuggageType.OGU: Color.ORANGE
	}
	color_rect.color = colors[luggage_type]
