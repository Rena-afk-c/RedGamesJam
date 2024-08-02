extends Control

@onready var base = $Base
@onready var counter_label = $Base/CounterLabel

var default_sprite_scale = Vector2(0.024, 0.024)
var target_sprite_position = Vector2(16, 19)

func _ready():
	GameManager.currency_updated.connect(_on_currency_updated)
	update_counter(GameManager.currency_flight)
func _on_currency_updated(new_amount: int):
	update_counter(new_amount)

func update_counter(amount: int):
	var tween = create_tween()
	
	tween.tween_property(counter_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(counter_label, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(counter_label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(counter_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	tween.parallel().tween_property(counter_label, "rotation_degrees", 5, 0.1)
	tween.parallel().tween_property(counter_label, "rotation_degrees", -5, 0.1)
	tween.parallel().tween_property(counter_label, "rotation_degrees", 0, 0.1)
	
	counter_label.text = " " + str(amount)  
