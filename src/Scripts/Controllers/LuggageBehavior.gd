extends RigidBody2D

enum LuggageType {TAPPY, BIGGIE, BAM, OGU}

var luggage_type: LuggageType
var can_be_collected = false

@onready var tappy_sprite = $Tappy
@onready var biggie_sprite = $BiggieSprite
@onready var bam_sprite = $Bam
@onready var ogu_sprite = $OguSprite
@onready var power_up_effects = $"/root/PowerUpEffects"

func _ready():
	luggage_type = LuggageType.values()[randi() % LuggageType.size()]
	set_luggage_sprite()
	print("Luggage initialized with type: ", LuggageType.keys()[luggage_type])
	power_up_effects.connect("luggage_free_for_all_activated", Callable(self, "_on_luggage_free_for_all_activated"))
	power_up_effects.connect("luggage_free_for_all_deactivated", Callable(self, "_on_luggage_free_for_all_deactivated"))

func set_luggage_sprite():
	tappy_sprite.hide()
	biggie_sprite.hide()
	bam_sprite.hide()
	ogu_sprite.hide()
	
	match luggage_type:
		LuggageType.TAPPY:
			tappy_sprite.show()
		LuggageType.BIGGIE:
			biggie_sprite.show()
		LuggageType.BAM:
			bam_sprite.show()
		LuggageType.OGU:
			ogu_sprite.show()

func _on_luggage_free_for_all_activated():
	for sprite in [tappy_sprite, biggie_sprite, bam_sprite, ogu_sprite]:
		if sprite.visible:
			sprite.modulate = Color.WHITE
	print("Luggage appearance changed for Free-For-All")

func _on_luggage_free_for_all_deactivated():
	set_luggage_sprite()
	for sprite in [tappy_sprite, biggie_sprite, bam_sprite, ogu_sprite]:
		sprite.modulate = Color.WHITE
	print("Luggage appearance reset to original")
