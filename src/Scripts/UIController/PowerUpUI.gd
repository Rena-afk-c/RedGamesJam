extends Control

@onready var luggage_automata_duration_label = $"CharacterPowerUp/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var time_slow_duration_label = $"CharacterPowerUp2/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var point_frenzy_duration_label = $"CharacterPowerUp3/VSplitContainer/PowerUpItem/PowerUp Duration"
@onready var luggage_free_for_all_duration_label = $"CharacterPowerUp4/VSplitContainer/PowerUpItem/PowerUp Duration"

@onready var luggage_automata_upgrade_button = $CharacterPowerUp/VSplitContainer/PowerUp1Btn
@onready var time_slow_upgrade_button = $CharacterPowerUp2/VSplitContainer/PowerUp2Btn
@onready var point_frenzy_upgrade_button = $CharacterPowerUp3/VSplitContainer/PowerUp3Btn
@onready var luggage_free_for_all_upgrade_button = $CharacterPowerUp4/VSplitContainer/PowerUp4Btn

@onready var animation_player = $"../../AnimationPlayer"

var upgrades = {
	"luggage_automata": {"duration": 5.0, "cost": 10, "label": null},
	"time_slow": {"duration": 5.0, "cost": 10, "label": null},
	"point_frenzy": {"duration": 5.0, "cost": 10, "label": null},
	"luggage_free_for_all": {"duration": 5.0, "cost": 10, "label": null}
}

var panelShowing = false
var currency_placeholder = 100

func _ready():
	upgrades["luggage_automata"].label = luggage_automata_duration_label
	upgrades["time_slow"].label = time_slow_duration_label
	upgrades["point_frenzy"].label = point_frenzy_duration_label
	upgrades["luggage_free_for_all"].label = luggage_free_for_all_duration_label
	
	for key in upgrades.keys():
		upgrades[key].label.text = String("%0.1f" % upgrades[key].duration) + ' s'
	
	_on_currency_updated(currency_placeholder)

func _on_currency_updated(new_amount: int):
	display_powerUpUI(new_amount)

func display_powerUpUI(amount: int):
	var should_show = false
	for key in upgrades.keys():
		if amount >= upgrades[key].cost:
			should_show = true
			break
	if should_show && !panelShowing:
		panelShowing = true
		animation_player.play("fade_in")
	if should_show:
		luggage_automata_upgrade_button.disabled = amount < upgrades["luggage_automata"].cost
		time_slow_upgrade_button.disabled = amount < upgrades["time_slow"].cost
		point_frenzy_upgrade_button.disabled = amount < upgrades["point_frenzy"].cost
		luggage_free_for_all_upgrade_button.disabled = amount < upgrades["luggage_free_for_all"].cost
	elif !should_show && panelShowing:
		animation_player.play("fade_out")
		panelShowing = false

func updateLabel(label: Label, amount: float):
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(label, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	tween.parallel().tween_property(label, "rotation_degrees", 5, 0.1)
	tween.parallel().tween_property(label, "rotation_degrees", -5, 0.1)
	tween.parallel().tween_property(label, "rotation_degrees", 0, 0.1)
	
	label.text = String("%0.1f" % amount) + ' s'

func upgrade_logic(upgrade_key: String):
	if currency_placeholder >= upgrades[upgrade_key].cost:
		currency_placeholder -= upgrades[upgrade_key].cost
		upgrades[upgrade_key].duration += 2.5
		upgrades[upgrade_key].cost *= 2
		updateLabel(upgrades[upgrade_key].label, upgrades[upgrade_key].duration)
		display_powerUpUI(currency_placeholder)
	
func _on_power_up_1_btn_pressed():
	upgrade_logic("luggage_automata")

func _on_power_up_2_btn_pressed():
	upgrade_logic("time_slow")

func _on_power_up_3_btn_pressed():
	upgrade_logic("point_frenzy")

func _on_power_up_4_btn_pressed():
	upgrade_logic("luggage_free_for_all")
