extends Control

@onready var counter_label = $Base/CounterLabel
@onready var luggage_automata_duration_label = $"CharacterPowerUp/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var time_slow_duration_label = $"CharacterPowerUp2/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var point_frenzy_duration_label = $"CharacterPowerUp3/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var luggage_free_for_all_duration_label = $"CharacterPowerUp4/VSplitContainer/PowerUpItem/PowerUp Duration"

var luggage_automata_duration = 5.0
var time_slow_duration_duration = 5.0
var point_frenzy_duration = 5.0
var luggage_free_for_all_duration = 5.0

func _ready():
	luggage_automata_duration_label.text = " " + str(luggage_automata_duration) + ' s'
	time_slow_duration_label.text = " " + str(time_slow_duration_duration) + ' s'
	point_frenzy_duration_label.text = " " + str(point_frenzy_duration) + ' s'
	luggage_free_for_all_duration_label.text = " " + str(luggage_free_for_all_duration) + ' s'
	
	GameManager.currency_updated.connect(_on_currency_updated)
	display_powerUpUI(GameManager.currency_flight)
	
func _on_currency_updated(new_amount: int):
	display_powerUpUI(new_amount)

func display_powerUpUI(amount: int):
	if (amount >= 10):
		hide() # fade out
	else:
		show() # fade in


	
func updateLabel(label:Label, amount: int):
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(label, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	tween.parallel().tween_property(label, "rotation_degrees", 5, 0.1)
	tween.parallel().tween_property(label, "rotation_degrees", -5, 0.1)
	tween.parallel().tween_property(label, "rotation_degrees", 0, 0.1)
	
	label.text = " " + str(amount) + ' s'

func _on_power_up_1_btn_pressed():
	luggage_automata_duration += 2.5
	updateLabel(luggage_automata_duration_label, luggage_automata_duration)

func _on_power_up_2_btn_pressed():
	time_slow_duration_duration += 2.5
	updateLabel(time_slow_duration_label, time_slow_duration_duration)

func _on_power_up_3_btn_pressed():
	point_frenzy_duration += 2.5
	updateLabel(point_frenzy_duration_label, point_frenzy_duration)

func _on_power_up_4_btn_pressed():
	luggage_free_for_all_duration += 2.5
	updateLabel(luggage_free_for_all_duration_label, luggage_free_for_all_duration)
