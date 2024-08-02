extends RigidBody2D

enum LuggageType {TAPPY, BIGGIE, BAM, OGU}
enum  character_type_selected {TAPPY, BIGGIE, BAM, OGU}
var luggage_type: LuggageType
var can_be_collected = false

@onready var collect_area = $CollectArea
@onready var color_rect = $ColorRect

func _ready():
	luggage_type = LuggageType.values()[randi() % LuggageType.size()]
	set_luggage_color()
	GameManager.character_selected.connect(_on_character_selected)
	_on_character_selected(GameManager.get_selected_character())

func set_luggage_color():
	var colors = {
		LuggageType.TAPPY: Color.GRAY,
		LuggageType.BIGGIE: Color.RED,
		LuggageType.BAM: Color.LIGHT_BLUE,
		LuggageType.OGU: Color.ORANGE
	}
	color_rect.color = colors[luggage_type]

func _physics_process(_delta):
	if collect_area.get_overlapping_bodies().has(self) and can_be_collected and Input.is_action_just_pressed("collect"):
		collect_luggage()

func _on_character_selected(character):
	can_be_collected = (character == luggage_type)

func collect_luggage():
	GameManager.collect_luggage()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)


func _on_collect_area_mouse_entered():
	print("COLLECTED AREA")
